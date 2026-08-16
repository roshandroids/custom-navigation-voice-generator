import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Moves to the next instruction in the recording workflow.
class GetNextInstruction {
  const GetNextInstruction(this._repository);

  final InstructionRepository _repository;

  Future<Result<Instruction>> execute({
    required VoicePackId packId,
    required InstructionId currentId,
  }) async {
    final result = await _repository.getForPack(packId);
    if (result.isErr) {
      return Err((result as Err<List<Instruction>>).failure);
    }

    final instructions = (result as Ok<List<Instruction>>).value;
    final index = instructions.indexWhere((i) => i.id == currentId);
    if (index == -1 || index + 1 >= instructions.length) {
      return const Err(NotFoundFailure('No next instruction.'));
    }
    return Ok(instructions[index + 1]);
  }
}
