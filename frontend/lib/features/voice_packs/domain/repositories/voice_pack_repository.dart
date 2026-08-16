import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Contract for voice pack storage.
///
/// The domain only knows this interface — not whether the implementation is
/// in-memory, a local database, or a remote backend.
abstract interface class VoicePackRepository {
  Future<Result<VoicePack>> create(VoicePack voice);

  Future<Result<VoicePack>> getById(VoicePackId id);

  Future<Result<List<VoicePack>>> getAll();
}
