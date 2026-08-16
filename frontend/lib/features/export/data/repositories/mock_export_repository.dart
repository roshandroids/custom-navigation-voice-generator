import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';

/// Mock export: simulates building a voice pack bundle.
///
/// Real ZIP creation is not part of the frontend MVP — this satisfies the
/// domain contract so a filesystem/backend implementation can be added later
/// without touching presentation or domain.
class MockExportRepository implements ExportRepository {
  MockExportRepository({this.exportDelay = const Duration(milliseconds: 400)});

  final Duration exportDelay;

  @override
  Future<Result<ExportBundle>> export({
    required String packName,
    required bool includeCleanAudio,
    required bool includeRecordingAudio,
  }) async {
    await Future<void>.delayed(exportDelay);
    // 25 instructions x 1 clean file each; recording-ready shares the same
    // file count in this simulation.
    const instructionCount = 25;
    return Ok(
      ExportBundle(
        packName: packName,
        fileCount: instructionCount,
        totalBytes: instructionCount * 4096,
      ),
    );
  }
}
