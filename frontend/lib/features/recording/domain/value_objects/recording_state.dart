import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';

/// The phase of the recording workflow.
enum RecordingPhase {
  /// Not recording. The user is on the editor screen.
  idle,

  /// The visual preparation countdown is running (or about to run).
  preparing,

  /// The generated audio is playing and the user is recording it into Waze.
  playing,

  /// Playback finished; the user can now mark the instruction as recorded.
  completed,

  /// The user confirmed the recording; the instruction is recorded.
  recorded,
}

/// The recording workflow state machine.
///
/// Valid transitions:
///
/// ```
/// idle ──beginPreparation──▶ preparing ──tick×3──▶ playing
///   ▲                          │                    │
///   │                          └──startPlayback──▶ playing
///   │ reset                                            │ completePlayback
///   │                                                  ▼
///   └────────────────────────────── recorded ◀── completed
/// ```
///
/// Invalid transitions return an [InvalidTransitionFailure]; the machine
/// never throws and never mutates — every transition returns a new state.
sealed class RecordingState {
  const RecordingState();

  RecordingPhase get phase;

  /// Seconds remaining in the preparation countdown (0 outside preparing).
  int get countdownRemaining => 0;

  /// Start the visual preparation countdown. Only valid from [RecordingIdle].
  Result<RecordingState> beginPreparation() =>
      Err(InvalidTransitionFailure('Cannot prepare in $phase phase.'));

  /// Advance the countdown by one second. When it reaches zero the workflow
  /// moves to [RecordingPhase.playing]. Only valid while preparing.
  Result<RecordingState> tick() =>
      Err(InvalidTransitionFailure('Cannot tick in $phase phase.'));

  /// Skip the countdown and start playback immediately.
  Result<RecordingState> startPlayback() =>
      Err(InvalidTransitionFailure('Cannot play in $phase phase.'));

  /// Playback finished. Only valid while playing.
  Result<RecordingState> completePlayback() =>
      Err(InvalidTransitionFailure('Cannot complete in $phase phase.'));

  /// Confirm the recording. Only valid from completed.
  Result<RecordingState> markRecorded() =>
      Err(InvalidTransitionFailure('Cannot record in $phase phase.'));

  /// Return to idle — used when moving to the next instruction.
  Result<RecordingState> reset() =>
      Err(InvalidTransitionFailure('Cannot reset in $phase phase.'));
}

final class RecordingIdle extends RecordingState {
  const RecordingIdle();

  @override
  RecordingPhase get phase => RecordingPhase.idle;

  @override
  Result<RecordingState> beginPreparation() =>
      Ok(RecordingPreparing(countdownRemaining: 3));

  @override
  Result<RecordingState> reset() => const Ok(RecordingIdle());
}

final class RecordingPreparing extends RecordingState {
  const RecordingPreparing({required int countdownRemaining})
      : _countdownRemaining = countdownRemaining;

  final int _countdownRemaining;

  @override
  RecordingPhase get phase => RecordingPhase.preparing;

  @override
  int get countdownRemaining => _countdownRemaining;

  @override
  Result<RecordingState> tick() {
    if (_countdownRemaining > 1) {
      return Ok(
        RecordingPreparing(countdownRemaining: _countdownRemaining - 1),
      );
    }
    return const Ok(RecordingPlaying());
  }

  @override
  Result<RecordingState> startPlayback() => const Ok(RecordingPlaying());
}

final class RecordingPlaying extends RecordingState {
  const RecordingPlaying();

  @override
  RecordingPhase get phase => RecordingPhase.playing;

  @override
  Result<RecordingState> completePlayback() => const Ok(RecordingCompleted());
}

final class RecordingCompleted extends RecordingState {
  const RecordingCompleted();

  @override
  RecordingPhase get phase => RecordingPhase.completed;

  @override
  Result<RecordingState> startPlayback() => const Ok(RecordingPlaying());

  @override
  Result<RecordingState> markRecorded() => const Ok(RecordingRecorded());
}

final class RecordingRecorded extends RecordingState {
  const RecordingRecorded();

  @override
  RecordingPhase get phase => RecordingPhase.recorded;

  @override
  Result<RecordingState> startPlayback() => const Ok(RecordingPlaying());

  @override
  Result<RecordingState> reset() => const Ok(RecordingIdle());
}
