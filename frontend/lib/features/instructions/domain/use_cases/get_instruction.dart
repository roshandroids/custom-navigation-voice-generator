import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Loads a single instruction by pack + instruction id.
class GetInstruction {
  const GetInstruction(this._repository);

  final InstructionRepository _repository;

  Future<Result<Instruction>> execute(
    VoicePackId packId,
    InstructionId id,
  ) =>
      _repository.getById(packId, id);
}
