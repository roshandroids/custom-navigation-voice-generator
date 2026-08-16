import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

void main() {
  group('VoicePack', () {
    test('creates a voice pack with all attributes', () {
      final pack = VoicePack(
        id: const VoicePackId('pack-1'),
        name: (VoicePackName.create('My Nepali Voice') as Ok<VoicePackName>).value,
        language: VoiceLanguage.nepali,
        voice: VoiceCatalog.nepali.first,
        personality: Personality.savage,
        createdAt: DateTime(2026, 8, 15),
      );

      expect(pack.id.value, 'pack-1');
      expect(pack.name.value, 'My Nepali Voice');
      expect(pack.language, VoiceLanguage.nepali);
      expect(pack.voice.id, 'chitwan');
      expect(pack.personality, Personality.savage);
      expect(pack.createdAt, DateTime(2026, 8, 15));
    });

    test('voice catalog exposes per-language voices and defaults', () {
      expect(VoiceCatalog.forLanguage(VoiceLanguage.nepali).length, 3);
      expect(VoiceCatalog.forLanguage(VoiceLanguage.english).length, 3);
      expect(VoiceCatalog.defaultFor(VoiceLanguage.nepali).id, 'chitwan');
      expect(VoiceCatalog.defaultFor(VoiceLanguage.english).id, 'joe');
      expect(VoiceCatalog.byId('kristin')?.language, VoiceLanguage.english);
      expect(VoiceCatalog.byId('google-medium')?.language, VoiceLanguage.nepali);
      expect(VoiceCatalog.byId('does-not-exist'), isNull);
    });

    test('personality provides example text for each language', () {
      for (final personality in Personality.values) {
        expect(personality.exampleFor(VoiceLanguage.nepali), isNotEmpty);
        expect(personality.exampleFor(VoiceLanguage.english), isNotEmpty);
      }
    });
  });
}
