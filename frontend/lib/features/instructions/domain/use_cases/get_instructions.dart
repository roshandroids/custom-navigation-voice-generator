import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Loads all instructions of a voice pack in corpus order.
class GetInstructions {
  const GetInstructions(this._repository);

  final InstructionRepository _repository;

  Future<Result<List<Instruction>>> execute(VoicePackId packId) =>
      _repository.getForPack(packId);
}
