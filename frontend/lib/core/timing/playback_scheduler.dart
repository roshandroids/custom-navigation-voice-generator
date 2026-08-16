import 'dart:async';

/// Schedules a one-shot callback after a delay — used for simulated playback
/// completion in the recording workflow.
///
/// Like [CountdownTicker], this keeps timers out of widgets and notifiers so
/// tests can fire completion deterministically with a fake.
abstract interface class PlaybackScheduler {
  /// Schedules [onComplete] to run after [delay]. Replaces any previous
  /// pending schedule.
  void schedule(Duration delay, void Function() onComplete);

  /// Cancels any pending schedule. Safe to call multiple times.
  void cancel();
}

/// Production scheduler backed by a [Timer].
final class TimerPlaybackScheduler implements PlaybackScheduler {
  Timer? _timer;

  @override
  void schedule(Duration delay, void Function() onComplete) {
    _timer?.cancel();
    _timer = Timer(delay, onComplete);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
