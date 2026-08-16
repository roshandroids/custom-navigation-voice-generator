import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';

void main() {
  group('VoicePackProgress', () {
    test('zero completed', () {
      final result = VoicePackProgress.create(recorded: 0, total: 25);
      final progress = (result as Ok<VoicePackProgress>).value;
      expect(progress.recorded, 0);
      expect(progress.total, 25);
      expect(progress.fraction, 0);
      expect(progress.isComplete, isFalse);
    });

    test('partially completed', () {
      final progress =
          (VoicePackProgress.create(recorded: 12, total: 25) as Ok<VoicePackProgress>).value;
      expect(progress.fraction, closeTo(0.48, 0.001));
      expect(progress.isComplete, isFalse);
    });

    test('fully completed', () {
      final progress =
          (VoicePackProgress.create(recorded: 25, total: 25) as Ok<VoicePackProgress>).value;
      expect(progress.fraction, 1);
      expect(progress.isComplete, isTrue);
    });

    test('empty pack progress is zero, not complete', () {
      final progress =
          (VoicePackProgress.create(recorded: 0, total: 0) as Ok<VoicePackProgress>).value;
      expect(progress.fraction, 0);
      expect(progress.isComplete, isFalse);
    });

    test('rejects negative counts', () {
      expect(
        VoicePackProgress.create(recorded: -1, total: 25).isOk,
        isFalse,
      );
      expect(
        VoicePackProgress.create(recorded: 0, total: -1).isOk,
        isFalse,
      );
    });

    test('rejects recorded greater than total', () {
      final result = VoicePackProgress.create(recorded: 26, total: 25);
      expect(result.isOk, isFalse);
      expect((result as Err<VoicePackProgress>).failure, isA<ValidationFailure>());
    });
  });
}
