import 'package:navigation_voice_generator/core/result/result.dart';

/// A voice pack export bundle.
///
/// The MVP does not create real ZIP files; this is the domain contract so a
/// future implementation (local files, ZIP, backend) can be added without
/// touching presentation or domain.
final class ExportBundle {
  const ExportBundle({
    required this.packName,
    required this.fileCount,
    required this.totalBytes,
  });

  final String packName;
  final int fileCount;
  final int totalBytes;
}

/// Contract for exporting a voice pack.
abstract interface class ExportRepository {
  Future<Result<ExportBundle>> export({
    required String packName,
    required bool includeCleanAudio,
    required bool includeRecordingAudio,
  });
}
