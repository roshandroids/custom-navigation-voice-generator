import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/create_voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/get_voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/use_cases/get_voice_packs.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

class FakeVoicePackRepository implements VoicePackRepository {
  final List<VoicePack> _packs = [];
  Failure? failure;

  @override
  Future<Result<VoicePack>> create(VoicePack voice) async {
    if (failure != null) return Err(failure!);
    _packs.add(voice);
    return Ok(voice);
  }

  @override
  Future<Result<VoicePack>> getById(VoicePackId id) async {
    if (failure != null) return Err(failure!);
    for (final pack in _packs) {
      if (pack.id == id) return Ok(pack);
    }
    return const Err(NotFoundFailure('Voice pack not found.'));
  }

  @override
  Future<Result<List<VoicePack>>> getAll() async {
    if (failure != null) return Err(failure!);
    return Ok(List.of(_packs));
  }
}

VoicePack packWithId(String id) => VoicePack(
      id: VoicePackId(id),
      name: (VoicePackName.create('My Voice') as Ok<VoicePackName>).value,
      language: VoiceLanguage.nepali,
      voice: VoiceCatalog.nepali.first,
      personality: Personality.savage,
      createdAt: DateTime(2026, 8, 15),
    );

void main() {
  group('CreateVoicePack', () {
    test('creates a pack and stores it', () async {
      final repository = FakeVoicePackRepository();
      final useCase = CreateVoicePack(repository);
      final pack = packWithId('pack-1');

      final result = await useCase.execute(pack);

      expect(result.isOk, isTrue);
      expect((result as Ok<VoicePack>).value, same(pack));
      expect(repository._packs, hasLength(1));
    });

    test('propagates repository failure', () async {
      final repository = FakeVoicePackRepository()..failure = const RepositoryFailure('storage down');
      final useCase = CreateVoicePack(repository);

      final result = await useCase.execute(packWithId('pack-1'));

      expect(result.isErr, isTrue);
      expect((result as Err<VoicePack>).failure, isA<RepositoryFailure>());
    });
  });

  group('GetVoicePack', () {
    test('returns the requested pack', () async {
      final repository = FakeVoicePackRepository();
      await repository.create(packWithId('pack-1'));

      final result = await GetVoicePack(repository).execute(const VoicePackId('pack-1'));

      expect(result.isOk, isTrue);
      expect((result as Ok<VoicePack>).value.id.value, 'pack-1');
    });

    test('returns NotFoundFailure for a missing pack', () async {
      final repository = FakeVoicePackRepository();
      final result = await GetVoicePack(repository).execute(const VoicePackId('missing'));

      expect(result.isErr, isTrue);
      expect((result as Err<VoicePack>).failure, isA<NotFoundFailure>());
    });

    test('propagates repository failure', () async {
      final repository = FakeVoicePackRepository()..failure = const RepositoryFailure('storage down');
      final result = await GetVoicePack(repository).execute(const VoicePackId('pack-1'));

      expect(result.isErr, isTrue);
      expect((result as Err<VoicePack>).failure, isA<RepositoryFailure>());
    });
  });

  group('GetVoicePacks', () {
    test('returns all packs in insertion order', () async {
      final repository = FakeVoicePackRepository();
      await repository.create(packWithId('pack-1'));
      await repository.create(packWithId('pack-2'));

      final result = await GetVoicePacks(repository).execute();

      expect(result.isOk, isTrue);
      expect((result as Ok<List<VoicePack>>).value.map((p) => p.id.value), ['pack-1', 'pack-2']);
    });

    test('returns an empty list when there are no packs', () async {
      final result = await GetVoicePacks(FakeVoicePackRepository()).execute();

      expect(result.isOk, isTrue);
      expect((result as Ok<List<VoicePack>>).value, isEmpty);
    });

    test('propagates repository failure', () async {
      final repository = FakeVoicePackRepository()..failure = const RepositoryFailure('storage down');
      final result = await GetVoicePacks(repository).execute();

      expect(result.isErr, isTrue);
      expect((result as Err<List<VoicePack>>).failure, isA<RepositoryFailure>());
    });
  });
}
