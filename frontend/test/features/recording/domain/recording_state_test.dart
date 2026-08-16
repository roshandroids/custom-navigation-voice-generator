import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';

void main() {
  RecordingState unwrap(Result<RecordingState> result) => (result as Ok<RecordingState>).value;

  group('RecordingState: idle', () {
    test('beginPreparation moves to preparing with countdown 3', () {
      final state = unwrap(const RecordingIdle().beginPreparation());
      expect(state.phase, RecordingPhase.preparing);
      expect(state.countdownRemaining, 3);
    });

    test('tick, startPlayback, completePlayback and markRecorded are invalid from idle', () {
      const idle = RecordingIdle();
      expect(idle.tick().isOk, isFalse);
      expect(idle.startPlayback().isOk, isFalse);
      expect(idle.completePlayback().isOk, isFalse);
      expect(idle.markRecorded().isOk, isFalse);
    });

    test('reset stays idle', () {
      expect(const RecordingIdle().reset().isOk, isTrue);
    });
  });

  group('RecordingState: preparing countdown', () {
    test('countdown ticks 3 -> 2 -> 1 -> playing', () {
      var state = unwrap(const RecordingIdle().beginPreparation());
      state = unwrap(state.tick());
      expect(state.phase, RecordingPhase.preparing);
      expect(state.countdownRemaining, 2);

      state = unwrap(state.tick());
      expect(state.phase, RecordingPhase.preparing);
      expect(state.countdownRemaining, 1);

      state = unwrap(state.tick());
      expect(state.phase, RecordingPhase.playing);
    });

    test('startPlayback skips directly to playing', () {
      final state = unwrap(const RecordingIdle().beginPreparation());
      final playing = unwrap(state.startPlayback());
      expect(playing.phase, RecordingPhase.playing);
    });

    test('beginPreparation, completePlayback and markRecorded are invalid while preparing', () {
      final preparing = unwrap(const RecordingIdle().beginPreparation());
      expect(preparing.beginPreparation().isOk, isFalse);
      expect(preparing.completePlayback().isOk, isFalse);
      expect(preparing.markRecorded().isOk, isFalse);
    });
  });

  group('RecordingState: playing', () {
    test('completePlayback moves to completed', () {
      final playing = unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback());
      final completed = unwrap(playing.completePlayback());
      expect(completed.phase, RecordingPhase.completed);
    });

    test('tick, startPlayback, beginPreparation and markRecorded are invalid while playing', () {
      final playing = unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback());
      expect(playing.tick().isOk, isFalse);
      expect(playing.startPlayback().isOk, isFalse);
      expect(playing.beginPreparation().isOk, isFalse);
      expect(playing.markRecorded().isOk, isFalse);
    });
  });

  group('RecordingState: completed', () {
    test('markRecorded moves to recorded', () {
      final completed =
          unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback());
      final recorded = unwrap(completed.markRecorded());
      expect(recorded.phase, RecordingPhase.recorded);
    });

    test('startPlayback replays from completed', () {
      final completed =
          unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback());
      expect(unwrap(completed.startPlayback()).phase, RecordingPhase.playing);
    });

    test('completePlayback is invalid from completed', () {
      final completed =
          unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback());
      expect(completed.completePlayback().isOk, isFalse);
    });
  });

  group('RecordingState: recorded', () {
    test('markRecorded again is invalid (recorded -> recorded prevented)', () {
      final recorded =
          unwrap(unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback()).markRecorded());
      final result = recorded.markRecorded();
      expect(result.isOk, isFalse);
      expect((result as Err<RecordingState>).failure, isA<InvalidTransitionFailure>());
    });

    test('startPlayback replays from recorded', () {
      final recorded =
          unwrap(unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback()).markRecorded());
      expect(unwrap(recorded.startPlayback()).phase, RecordingPhase.playing);
    });

    test('reset moves to idle (next instruction)', () {
      final recorded =
          unwrap(unwrap(unwrap(unwrap(const RecordingIdle().beginPreparation()).startPlayback()).completePlayback()).markRecorded());
      expect(unwrap(recorded.reset()).phase, RecordingPhase.idle);
    });
  });
}
