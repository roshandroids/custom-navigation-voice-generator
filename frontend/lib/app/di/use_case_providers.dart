import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_instructions.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_next_instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_previous_instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_voice_pack_progress.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/mark_instruction_recorded.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/update_instruction_text.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/use_cases/generate_instruction_suggestions.dart';
import 'package:navigation_voice_generator/features/tts/domain/use_cases/generate_instruction_audio.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/create_voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/get_voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/get_voice_packs.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Use-case providers: one provider per use case, each depending on the
/// repository providers. The presentation layer depends only on these.

final createVoicePackProvider = Provider((ref) {
  return CreateVoicePack(ref.watch(voicePackRepositoryProvider));
});

final getVoicePackProvider = Provider((ref) {
  return GetVoicePack(ref.watch(voicePackRepositoryProvider));
});

final getVoicePacksProvider = Provider((ref) {
  return GetVoicePacks(ref.watch(voicePackRepositoryProvider));
});

/// Per-pack lookup as an [AsyncValue] for direct widget watching.
final packByIdProvider =
    FutureProvider.family<VoicePack, VoicePackId>((ref, packId) async {
  final result = await GetVoicePack(ref.watch(voicePackRepositoryProvider)).execute(packId);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final getInstructionProvider = Provider((ref) {
  return GetInstruction(ref.watch(instructionRepositoryProvider));
});

/// Per-pack instructions as an [AsyncValue] for direct widget watching.
final packInstructionsProvider = FutureProvider.family<List<Instruction>, VoicePackId>(
  (ref, packId) async {
    final result = await GetInstructions(
      ref.watch(instructionRepositoryProvider),
    ).execute(packId);
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  },
);

final getInstructionsProvider = Provider((ref) {
  return GetInstructions(ref.watch(instructionRepositoryProvider));
});

final getVoicePackProgressProvider = Provider((ref) {
  return GetVoicePackProgress(ref.watch(instructionRepositoryProvider));
});

/// Per-pack progress, exposed as an [AsyncValue] so widgets can watch it
/// directly.
final packProgressProvider = FutureProvider.family<VoicePackProgress, VoicePackId>((ref, packId) async {
  final result = await GetVoicePackProgress(ref.watch(instructionRepositoryProvider)).execute(packId);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});

final updateInstructionTextProvider = Provider((ref) {
  return UpdateInstructionText(ref.watch(instructionRepositoryProvider));
});

final markInstructionRecordedProvider = Provider((ref) {
  return MarkInstructionRecorded(ref.watch(instructionRepositoryProvider));
});

final getNextInstructionProvider = Provider((ref) {
  return GetNextInstruction(ref.watch(instructionRepositoryProvider));
});

final getPreviousInstructionProvider = Provider((ref) {
  return GetPreviousInstruction(ref.watch(instructionRepositoryProvider));
});

final generateInstructionAudioProvider = Provider((ref) {
  return GenerateInstructionAudio(ref.watch(ttsRepositoryProvider));
});

final generateInstructionSuggestionsProvider = Provider((ref) {
  return GenerateInstructionSuggestions(ref.watch(suggestionRepositoryProvider));
});
