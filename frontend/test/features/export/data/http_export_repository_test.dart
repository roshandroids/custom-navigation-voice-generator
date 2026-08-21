import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/data/repositories/http_export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';

final _baseUrl = 'http://127.0.0.1:8000';

(Dio, DioAdapter) _mockedDio() {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

void main() {
  test('export posts to the pack endpoint and maps the bundle', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/voice-packs/pack-1/export',
      (server) =>
          server.reply(200, {'packName': 'My Pack', 'fileCount': 12, 'totalBytes': 48128}),
      data: {'includeCleanAudio': true, 'includeRecordingAudio': false},
    );
    final repo = HttpExportRepository(dio: dio);

    final result = await repo.export(
      packId: 'pack-1',
      packName: 'My Pack',
      includeCleanAudio: true,
      includeRecordingAudio: false,
    );
    expect(result.isOk, isTrue);
    final bundle = (result as Ok<ExportBundle>).value;
    expect(bundle.packName, 'My Pack');
    expect(bundle.fileCount, 12);
    expect(bundle.totalBytes, 48128);
  });

  test('export 404 maps to a failure', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost('/v1/voice-packs/nope/export', (server) => server.reply(404, {'detail': 'nope'}));
    final repo = HttpExportRepository(dio: dio);

    final result = await repo.export(
      packId: 'nope',
      packName: 'Missing',
      includeCleanAudio: true,
      includeRecordingAudio: true,
    );
    expect(result.isErr, isTrue);
  });
}