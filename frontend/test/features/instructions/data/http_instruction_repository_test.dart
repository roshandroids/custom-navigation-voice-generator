import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/data/repositories/http_instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

final _baseUrl = 'http://127.0.0.1:8000';
const _packId = VoicePackId('seed-en');

const _instructionJson = {
  'id': 'en_turn_left_001',
  'category': 'directions',
  'situation': 'Turn left',
  'standardText': 'Turn left.',
  'customText': 'Turn left.',
  'audioUrl': '/v1/audio/abc.wav',
  'isRecorded': false,
};

(Dio, DioAdapter) _mockedDio() {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

void main() {
  test('getForPack maps the instruction list', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/seed-en/instructions',
      (server) => server.reply(200, [_instructionJson]),
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result = await repo.getForPack(_packId);
    expect(result.isOk, isTrue);
    final instructions = (result as Ok<List<Instruction>>).value;
    expect(instructions.length, 1);
    final i = instructions.single;
    expect(i.id.value, 'en_turn_left_001');
    expect(i.category, InstructionCategory.directions);
    expect(i.isRecorded, isFalse);
    // audioUrl resolves to an absolute uri for playback.
    expect(i.audio, isNotNull);
    expect(i.audio!.uri, Uri.parse('http://127.0.0.1:8000/v1/audio/abc.wav'));
  });

  test('getById returns a single instruction', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/seed-en/instructions/en_turn_left_001',
      (server) => server.reply(200, _instructionJson),
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result =
        await repo.getById(_packId, const InstructionId('en_turn_left_001'));
    expect((result as Ok<Instruction>).value.id.value, 'en_turn_left_001');
  });

  test('updateCustomText sends a PATCH and returns the updated instruction', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPatch(
      '/v1/voice-packs/seed-en/instructions/en_turn_left_001',
      (server) => server.reply(200, {..._instructionJson, 'customText': 'Try this.'}),
      data: {'customText': 'Try this.'},
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result = await repo.updateCustomText(
      packId: _packId,
      id: const InstructionId('en_turn_left_001'),
      text: 'Try this.',
    );
    expect((result as Ok<Instruction>).value.customText, 'Try this.');
  });

  test('markRecorded sends isRecorded and returns the recorded instruction', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPatch(
      '/v1/voice-packs/seed-en/instructions/en_turn_left_001',
      (server) => server.reply(200, {..._instructionJson, 'isRecorded': true}),
      data: {'isRecorded': true},
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result = await repo.markRecorded(
      packId: _packId,
      id: const InstructionId('en_turn_left_001'),
    );
    expect((result as Ok<Instruction>).value.isRecorded, isTrue);
  });

  test('attachAudio sends a PUT with the audio url', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPut(
      '/v1/voice-packs/seed-en/instructions/en_turn_left_001/audio',
      (server) =>
          server.reply(200, {..._instructionJson, 'audioUrl': '/v1/audio/abc.wav'}),
      data: {'audioUrl': 'http://127.0.0.1:8000/v1/audio/abc.wav'},
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result = await repo.attachAudio(
      packId: _packId,
      id: const InstructionId('en_turn_left_001'),
      audio: AudioAsset(
        id: const AudioAssetId('a'),
        duration: Duration.zero,
        format: AudioFormat.wav,
        kind: AudioKind.clean,
        uri: Uri.parse('http://127.0.0.1:8000/v1/audio/abc.wav'),
      ),
    );
    expect((result as Ok<Instruction>).value.audio, isNotNull);
  });

  test('countForPack uses the progress totals', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/seed-en/progress',
      (server) => server.reply(200, {'recorded': 2, 'total': 22}),
    );
    final repo = HttpInstructionRepository(dio: dio);

    expect((await repo.countForPack(_packId) as Ok<int>).value, 22);
    expect((await repo.countRecordedForPack(_packId) as Ok<int>).value, 2);
  });

  test('getById 404 maps to a NotFoundFailure', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onGet(
      '/v1/voice-packs/seed-en/instructions/nope',
      (server) => server.reply(404, {'detail': 'not found'}),
    );
    final repo = HttpInstructionRepository(dio: dio);

    final result = await repo.getById(_packId, const InstructionId('nope'));
    expect((result as Err<Instruction>).failure.runtimeType.toString(),
        contains('NotFound'));
  });
}