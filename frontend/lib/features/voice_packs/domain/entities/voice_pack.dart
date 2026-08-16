import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// A voice pack: a named, single-language collection of navigation
/// instructions with a voice and a personality.
final class VoicePack {
  const VoicePack({
    required this.id,
    required this.name,
    required this.language,
    required this.voice,
    required this.personality,
    required this.createdAt,
  });

  final VoicePackId id;
  final VoicePackName name;
  final VoiceLanguage language;
  final VoiceProfile voice;
  final Personality personality;
  final DateTime createdAt;
}
