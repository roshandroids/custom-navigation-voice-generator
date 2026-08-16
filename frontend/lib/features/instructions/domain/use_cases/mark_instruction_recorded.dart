import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Marks an instruction as recorded in the workflow.
class MarkInstructionRecorded {
  const MarkInstructionRecorded(this._repository);

  final InstructionRepository _repository;

  Future<Result<Instruction>> execute({
    required VoicePackId packId,
    required InstructionId instructionId,
  }) =>
      _repository.markRecorded(packId: packId, id: instructionId);
}
