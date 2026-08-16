import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';

/// Loads all voice packs, most recently created first.
class GetVoicePacks {
  const GetVoicePacks(this._repository);

  final VoicePackRepository _repository;

  Future<Result<List<VoicePack>>> execute() async {
    final result = await _repository.getAll();
    if (result.isErr) return result;
    final packs = List<VoicePack>.of((result as Ok<List<VoicePack>>).value);
    packs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Ok(packs);
  }
}
