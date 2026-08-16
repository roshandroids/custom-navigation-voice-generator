import 'dart:async';

/// A testable countdown used by the recording workflow.
///
/// The UI never depends directly on `Timer.periodic`: the recording notifier
/// depends on this abstraction, and tests inject a fake ticker so the
/// countdown is fully deterministic.
abstract interface class CountdownTicker {
  /// Starts ticking once per second. Calls [onTick] for each tick.
  void start(Duration interval, void Function() onTick);

  /// Stops ticking. Safe to call multiple times.
  void stop();
}

/// Production ticker backed by a [Timer].
final class TimerCountdownTicker implements CountdownTicker {
  Timer? _timer;

  @override
  void start(Duration interval, void Function() onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
