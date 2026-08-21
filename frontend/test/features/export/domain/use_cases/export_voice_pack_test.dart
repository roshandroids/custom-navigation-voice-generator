import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/use_cases/export_voice_pack.dart';

class FakeExportRepository implements ExportRepository {
  Failure? failure;
  bool? lastIncludeClean;
  bool? lastIncludeRecording;
  String? lastPackId;

  @override
  Future<Result<ExportBundle>> export({
    required String packId,
    required String packName,
    required bool includeCleanAudio,
    required bool includeRecordingAudio,
  }) async {
    lastPackId = packId;
    lastIncludeClean = includeCleanAudio;
    lastIncludeRecording = includeRecordingAudio;
    if (failure != null) return Err(failure!);
    return Ok(
      ExportBundle(packName: packName, fileCount: 25, totalBytes: 4096),
    );
  }
}

void main() {
  group('ExportVoicePack', () {
    test('exports a pack with the requested options', () async {
      final repository = FakeExportRepository();
      final useCase = ExportVoicePack(repository);

      final result = await useCase.execute(
        packId: 'pack-1',
        packName: 'My Nepali Voice',
        includeCleanAudio: true,
        includeRecordingAudio: false,
      );

      expect(result.isOk, isTrue);
      final bundle = (result as Ok<ExportBundle>).value;
      expect(bundle.packName, 'My Nepali Voice');
      expect(bundle.fileCount, 25);
      expect(repository.lastPackId, 'pack-1');
      expect(repository.lastIncludeClean, isTrue);
      expect(repository.lastIncludeRecording, isFalse);
    });

    test('rejects an empty pack name', () async {
      final result = await ExportVoicePack(FakeExportRepository()).execute(
        packId: 'pack-1',
        packName: '  ',
        includeCleanAudio: true,
        includeRecordingAudio: false,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<ExportBundle>).failure, isA<ValidationFailure>());
    });

    test('propagates repository failure', () async {
      final repository = FakeExportRepository()
        ..failure = const RepositoryFailure('export failed');
      final result = await ExportVoicePack(repository).execute(
        packId: 'pack-1',
        packName: 'My Nepali Voice',
        includeCleanAudio: true,
        includeRecordingAudio: true,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<ExportBundle>).failure, isA<RepositoryFailure>());
    });
  });
}
