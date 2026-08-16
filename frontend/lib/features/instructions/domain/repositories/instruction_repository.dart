import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Contract for instruction storage within a voice pack.
abstract interface class InstructionRepository {
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId);

  Future<Result<Instruction>> getById(VoicePackId packId, InstructionId id);

  Future<Result<Instruction>> updateCustomText({
    required VoicePackId packId,
    required InstructionId id,
    required String text,
  });

  Future<Result<Instruction>> attachAudio({
    required VoicePackId packId,
    required InstructionId id,
    required AudioAsset audio,
  });

  Future<Result<Instruction>> markRecorded({
    required VoicePackId packId,
    required InstructionId id,
  });

  /// The number of instructions in a pack (all of them).
  Future<Result<int>> countForPack(VoicePackId packId);

  /// The number of recorded instructions in a pack.
  Future<Result<int>> countRecordedForPack(VoicePackId packId);
}
