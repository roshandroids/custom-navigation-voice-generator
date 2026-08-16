import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';

/// Creates a new voice pack.
class CreateVoicePack {
  const CreateVoicePack(this._repository);

  final VoicePackRepository _repository;

  Future<Result<VoicePack>> execute(VoicePack voice) => _repository.create(voice);
}
