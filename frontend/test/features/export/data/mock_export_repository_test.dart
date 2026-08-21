import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/data/repositories/mock_export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';

void main() {
  group('MockExportRepository', () {
    test('builds an export bundle with the requested options', () async {
      final repository = MockExportRepository();
      final result = await repository.export(
        packId: 'pack-1',
        packName: 'My Nepali Voice',
        includeCleanAudio: true,
        includeRecordingAudio: false,
      );

      expect(result.isOk, isTrue);
      final bundle = (result as Ok<ExportBundle>).value;
      expect(bundle.packName, 'My Nepali Voice');
      expect(bundle.fileCount, greaterThan(0));
      expect(bundle.totalBytes, greaterThan(0));
    });

    test('recording-ready export includes the same files', () async {
      final repository = MockExportRepository();
      final clean = await repository.export(
        packId: 'pack-1',
        packName: 'Pack',
        includeCleanAudio: true,
        includeRecordingAudio: false,
      );
      final both = await repository.export(
        packId: 'pack-1',
        packName: 'Pack',
        includeCleanAudio: true,
        includeRecordingAudio: true,
      );

      expect((clean as Ok<ExportBundle>).value.fileCount, (both as Ok<ExportBundle>).value.fileCount);
    });
  });
}
