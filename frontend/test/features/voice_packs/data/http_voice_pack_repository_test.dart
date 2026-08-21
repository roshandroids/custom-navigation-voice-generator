import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/data/repositories/http_voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

final _baseUrl = 'http://127.0.0.1:8000';

const _seedPackJson = {
  'id': 'seed-ne',
  'name': 'My Nepali Voice',
  'language': 'ne',
  'voice': 'chitwan',
  'personality': 'savage',
  'createdAt': '2026-08-15T00:00:00',
};

(Dio, DioAdapter) _mockedDio() {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

void main() {
  test('getAll maps the server pack list', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs',
      (server) => server.reply(200, [_seedPackJson]),
    );
    final repo = HttpVoicePackRepository(dio: dio);

    final result = await repo.getAll();
    expect(result.isOk, isTrue);
    final packs = (result as Ok<List<VoicePack>>).value;
    expect(packs.length, 1);
    final pack = packs.single;
    expect(pack.id.value, 'seed-ne');
    expect(pack.language, VoiceLanguage.nepali);
    expect(pack.personality, Personality.savage);
  });

  test('getById returns a pack', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/seed-ne',
      (server) => server.reply(200, _seedPackJson),
    );
    final repo = HttpVoicePackRepository(dio: dio);

    final result = await repo.getById(const VoicePackId('seed-ne'));
    expect((result as Ok<VoicePack>).value.id.value, 'seed-ne');
  });

  test('getById 404 maps to NotFoundFailure', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/nope',
      (server) => server.reply(404, {'detail': 'not found'}),
    );
    final repo = HttpVoicePackRepository(dio: dio);

    final result = await repo.getById(const VoicePackId('nope'));
    expect(result.isErr, isTrue);
    expect((result as Err<VoicePack>).failure, isA<NotFoundFailure>());
  });

  test('create posts the pack and returns the server-assigned pack', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/voice-packs',
      (server) => server.reply(
        201,
        {
          'id': 'pack-1',
          'name': 'My Pack',
          'language': 'ne',
          'voice': 'chitwan',
          'personality': 'firm',
          'createdAt': '2026-08-21T00:00:00',
        },
      ),
      data: {
        'name': 'My Pack',
        'language': 'ne',
        'voice': 'chitwan',
        'personality': 'firm',
      },
    );
    final repo = HttpVoicePackRepository(dio: dio);

    final result = await repo.create(_pack());
    expect((result as Ok<VoicePack>).value.id.value, 'pack-1');
  });

  test('create server error maps to RepositoryFailure', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost('/v1/voice-packs', (server) => server.reply(500, {'detail': 'boom'}));
    final repo = HttpVoicePackRepository(dio: dio);

    final result = await repo.create(_pack());
    expect(result.isErr, isTrue);
    expect((result as Err<VoicePack>).failure, isA<RepositoryFailure>());
  });
}

VoicePack _pack() => VoicePack(
      id: const VoicePackId('client-id'),
      name: (VoicePackName.create('My Pack') as Ok<VoicePackName>).value,
      language: VoiceLanguage.nepali,
      voice: VoiceCatalog.nepali.first,
      personality: Personality.firm,
      createdAt: DateTime(2026, 8, 21),
    );