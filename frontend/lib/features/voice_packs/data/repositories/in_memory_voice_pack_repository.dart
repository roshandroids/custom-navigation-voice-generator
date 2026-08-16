import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// In-memory voice pack storage for the MVP.
class InMemoryVoicePackRepository implements VoicePackRepository {
  final Map<VoicePackId, VoicePack> _packs = {};

  @override
  Future<Result<VoicePack>> create(VoicePack voice) async {
    _packs[voice.id] = voice;
    return Ok(voice);
  }

  @override
  Future<Result<VoicePack>> getById(VoicePackId id) async {
    final pack = _packs[id];
    if (pack == null) {
      return const Err(NotFoundFailure('Voice pack not found.'));
    }
    return Ok(pack);
  }

  @override
  Future<Result<List<VoicePack>>> getAll() async =>
      Ok(List.unmodifiable(_packs.values));
}
