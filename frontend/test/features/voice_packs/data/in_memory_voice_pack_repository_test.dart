import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/data/repositories/in_memory_voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

void main() {
  group('InMemoryVoicePackRepository', () {
    test('create stores and getById retrieves a pack', () async {
      final repository = InMemoryVoicePackRepository();
      final pack = VoicePack(
        id: const VoicePackId('pack-1'),
        name: (VoicePackName.create('My Nepali Voice') as Ok<VoicePackName>).value,
        language: VoiceLanguage.nepali,
        voice: VoiceCatalog.nepali.first,
        personality: Personality.savage,
        createdAt: DateTime(2026, 8, 15),
      );

      final created = await repository.create(pack);
      expect(created.isOk, isTrue);

      final loaded = await repository.getById(const VoicePackId('pack-1'));
      expect(loaded.isOk, isTrue);
      expect((loaded as Ok<VoicePack>).value.name.value, 'My Nepali Voice');
    });

    test('getById returns NotFoundFailure for an unknown pack', () async {
      final repository = InMemoryVoicePackRepository();
      final result = await repository.getById(const VoicePackId('ghost'));
      expect(result.isErr, isTrue);
      expect(result.isErr, isTrue);
    });

    test('getAll returns created packs', () async {
      final repository = InMemoryVoicePackRepository();
      await repository.create(
        VoicePack(
          id: const VoicePackId('pack-1'),
          name: (VoicePackName.create('A') as Ok<VoicePackName>).value,
          language: VoiceLanguage.english,
          voice: VoiceCatalog.english.first,
          personality: Personality.normal,
          createdAt: DateTime(2026, 8, 15),
        ),
      );
      final result = await repository.getAll();
      expect(result.isOk, isTrue);
      expect((result as Ok<List<VoicePack>>).value, hasLength(1));
    });
  });
}
