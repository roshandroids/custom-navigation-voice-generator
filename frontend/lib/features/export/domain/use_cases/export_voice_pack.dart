import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';

/// Exports a completed voice pack.
class ExportVoicePack {
  const ExportVoicePack(this._repository);

  final ExportRepository _repository;

  Future<Result<ExportBundle>> execute({
    required String packName,
    required bool includeCleanAudio,
    required bool includeRecordingAudio,
  }) {
    if (packName.trim().isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Pack name cannot be empty.')),
      );
    }
    return _repository.export(
      packName: packName,
      includeCleanAudio: includeCleanAudio,
      includeRecordingAudio: includeRecordingAudio,
    );
  }
}
