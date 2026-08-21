import 'package:dio/dio.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';

/// HTTP export repository backed by the FastAPI service via `dio`
/// (`POST /v1/voice-packs/{id}/export`). The server assembles a ZIP bundle of
/// clean + recording-ready clips and returns the summary for [ExportBundle].
class HttpExportRepository implements ExportRepository {
  HttpExportRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Result<ExportBundle>> export({
    required String packId,
    required String packName,
    required bool includeCleanAudio,
    required bool includeRecordingAudio,
  }) async {
    try {
      final response = await _dio.post<void>(
        '/v1/voice-packs/$packId/export',
        data: {
          'includeCleanAudio': includeCleanAudio,
          'includeRecordingAudio': includeRecordingAudio,
        },
      );
      final json = response.data as Map<String, dynamic>;
      return Ok(
        ExportBundle(
          packName: json['packName'] as String,
          fileCount: (json['fileCount'] as num).toInt(),
          totalBytes: (json['totalBytes'] as num).toInt(),
        ),
      );
    } on DioException catch (error) {
      return Err(
        RepositoryFailure(
          'Could not export the voice pack (${error.response?.statusCode ?? 'network'}).',
        ),
      );
    }
  }
}