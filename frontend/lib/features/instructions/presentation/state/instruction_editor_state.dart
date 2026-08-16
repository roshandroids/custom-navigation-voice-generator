import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';

/// Status of a generation-style operation.
enum GenerationStatus {
  idle,
  loading,
  success,
  failure,
}

/// The instruction editor screen state.
///
/// Contains the loaded instruction, the local draft text (not persisted on
/// every keystroke), the audio-generation state, and the suggestions state.
final class InstructionEditorState {
  const InstructionEditorState({
    required this.isLoading,
    this.instruction,
    this.draftText,
    this.generationStatus = GenerationStatus.idle,
    this.audio,
    this.suggestions = const [],
    this.suggestionStatus = GenerationStatus.idle,
    this.audioErrorMessage,
    this.suggestionErrorMessage,
    this.saveErrorMessage,
  });

  const InstructionEditorState.loading() : this(isLoading: true);

  const InstructionEditorState.failure(String message)
      : this(
          isLoading: false,
          saveErrorMessage: message,
        );

  InstructionEditorState.data({
    required Instruction instruction,
    required String draftText,
  }) : this(
          isLoading: false,
          instruction: instruction,
          draftText: draftText,
        );

  final bool isLoading;
  final Instruction? instruction;
  final String? draftText;
  final GenerationStatus generationStatus;
  final AudioAsset? audio;
  final List<Suggestion> suggestions;
  final GenerationStatus suggestionStatus;
  final String? audioErrorMessage;
  final String? suggestionErrorMessage;
  final String? saveErrorMessage;

  InstructionEditorState copyWith({
    bool? isLoading,
    Instruction? instruction,
    String? draftText,
    GenerationStatus? generationStatus,
    AudioAsset? audio,
    List<Suggestion>? suggestions,
    GenerationStatus? suggestionStatus,
    String? audioErrorMessage,
    String? suggestionErrorMessage,
    String? saveErrorMessage,
    bool clearAudio = false,
    bool clearAudioError = false,
    bool clearSuggestionError = false,
    bool clearSaveError = false,
  }) =>
      InstructionEditorState(
        isLoading: isLoading ?? this.isLoading,
        instruction: instruction ?? this.instruction,
        draftText: draftText ?? this.draftText,
        generationStatus: generationStatus ?? this.generationStatus,
        audio: clearAudio ? null : (audio ?? this.audio),
        suggestions: suggestions ?? this.suggestions,
        suggestionStatus: suggestionStatus ?? this.suggestionStatus,
        audioErrorMessage: clearAudioError
            ? null
            : (audioErrorMessage ?? this.audioErrorMessage),
        suggestionErrorMessage: clearSuggestionError
            ? null
            : (suggestionErrorMessage ?? this.suggestionErrorMessage),
        saveErrorMessage: clearSaveError
            ? null
            : (saveErrorMessage ?? this.saveErrorMessage),
      );
}
