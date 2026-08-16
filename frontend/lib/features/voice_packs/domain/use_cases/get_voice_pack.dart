import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Loads a single voice pack by id.
class GetVoicePack {
  const GetVoicePack(this._repository);

  final VoicePackRepository _repository;

  Future<Result<VoicePack>> execute(VoicePackId id) => _repository.getById(id);
}
