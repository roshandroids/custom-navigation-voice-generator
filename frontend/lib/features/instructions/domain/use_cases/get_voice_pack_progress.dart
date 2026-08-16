import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';

/// Computes the recording progress of a voice pack.
class GetVoicePackProgress {
  const GetVoicePackProgress(this._repository);

  final InstructionRepository _repository;

  Future<Result<VoicePackProgress>> execute(VoicePackId packId) async {
    final totalResult = await _repository.countForPack(packId);
    if (totalResult.isErr) {
      return Err((totalResult as Err<int>).failure);
    }

    final recordedResult = await _repository.countRecordedForPack(packId);
    if (recordedResult.isErr) {
      return Err((recordedResult as Err<int>).failure);
    }

    return VoicePackProgress.create(
      recorded: (recordedResult as Ok<int>).value,
      total: (totalResult as Ok<int>).value,
    );
  }
}
