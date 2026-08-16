import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/state/instruction_editor_state.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// Coordinates the instruction editor: local draft, suggestion generation,
/// audio generation, and the explicit save action.
///
/// The draft is held locally; only the save action (or audio generation)
/// persists the text through the [UpdateInstructionText] use case.
class InstructionEditorNotifier extends Notifier<InstructionEditorState> {
  InstructionEditorNotifier(this.args);

  final InstructionEditorArgs args;

  String get packId => args.packId;
  String get instructionId => args.instructionId;
  VoiceProfile get voice => args.voice;
  VoiceLanguage get language => args.language;
  Personality get personality => args.personality;

  @override
  InstructionEditorState build() {
    _load();
    return const InstructionEditorState.loading();
  }

  Future<void> _load() async {
    final result = await ref
        .read(getInstructionProvider)
        .execute(VoicePackId(packId), InstructionId(instructionId));
    if (result.isErr) {
      state = InstructionEditorState.failure(_messageFor(result));
      return;
    }
    final instruction = (result as Ok<Instruction>).value;
    state = InstructionEditorState.data(
      instruction: instruction,
      draftText: instruction.customText,
    );
  }

  /// The user is typing — only the local draft changes.
  void updateDraft(String text) =>
      state = state.copyWith(draftText: text, clearSaveError: true);

  /// Applies a suggestion to the draft.
  void applySuggestion(String text) {
    state = state.copyWith(
      draftText: text,
      clearSaveError: true,
      clearAudio: true,
    );
  }

  /// Explicit save of the draft through the use case.
  Future<void> saveDraft() async {
    final instruction = state.instruction;
    final draft = state.draftText;
    if (instruction == null || draft == null) return;
    final result = await ref.read(updateInstructionTextProvider).execute(
          packId: VoicePackId(packId),
          instructionId: InstructionId(instructionId),
          text: draft,
        );
    if (result.isErr) {
      state = state.copyWith(saveErrorMessage: _messageFor(result));
      return;
    }
    final updated = (result as Ok<Instruction>).value;
    state = state.copyWith(
      instruction: updated,
      draftText: updated.customText,
      clearSaveError: true,
    );
  }

  /// Saves the draft, then generates audio for it.
  Future<void> generateAudio() async {
    final instruction = state.instruction;
    if (instruction == null) return;

    state = state.copyWith(
      generationStatus: GenerationStatus.loading,
      clearAudio: true,
      clearAudioError: true,
    );

    final text = state.draftText ?? instruction.customText;
    final saveResult = await ref.read(updateInstructionTextProvider).execute(
          packId: VoicePackId(packId),
          instructionId: InstructionId(instructionId),
          text: text,
        );
    if (saveResult.isErr) {
      state = state.copyWith(
        generationStatus: GenerationStatus.failure,
        audioErrorMessage: _messageFor(saveResult),
      );
      return;
    }
    final saved = (saveResult as Ok<Instruction>).value;
    state = state.copyWith(instruction: saved, draftText: saved.customText);

    final audioResult = await ref.read(generateInstructionAudioProvider).execute(
          text: saved.customText,
          language: language,
          voice: voice,
        );
    if (audioResult.isErr) {
      state = state.copyWith(
        generationStatus: GenerationStatus.failure,
        audioErrorMessage: _messageFor(audioResult),
      );
      return;
    }
    final asset = (audioResult as Ok<AudioAsset>).value;
    state = state.copyWith(
      generationStatus: GenerationStatus.success,
      audio: asset,
      clearAudioError: true,
    );
  }

  Future<void> generateSuggestions() async {
    final instruction = state.instruction;
    if (instruction == null) return;

    state = state.copyWith(
      suggestionStatus: GenerationStatus.loading,
      clearSuggestionError: true,
    );

    final result = await ref
        .read(generateInstructionSuggestionsProvider)
        .execute(
          situation: instruction.situation,
          standardText: instruction.standardText,
          personality: personality,
          language: language,
        );
    if (result.isErr) {
      state = state.copyWith(
        suggestionStatus: GenerationStatus.failure,
        suggestionErrorMessage: _messageFor(result),
      );
      return;
    }
    final suggestions = (result as Ok<List<Suggestion>>).value;
    state = state.copyWith(
      suggestionStatus: GenerationStatus.success,
      suggestions: suggestions,
      clearSuggestionError: true,
    );
  }
}

String _messageFor(Result result) {
  final failure = result is Err ? result.failure : const UnexpectedFailure('Unknown error.');
  return _friendlyMessage(failure);
}

String _friendlyMessage(Failure failure) => switch (failure) {
      ValidationFailure(:final message) => message,
      TtsGenerationFailure(:final message) => message,
      SuggestionFailure(:final message) => message,
      NotFoundFailure() => 'Not found.',
      _ => 'Something went wrong.',
    };
