import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart' as audio;

/// Plays an audio source and reports when playback actually ends.
///
/// The recording workflow used a [Timer]-based [PlaybackScheduler] to advance
/// after a fixed delay. Real playback needs an `onComplete` signal tied to the
/// audio genuinely finishing. This abstraction keeps `audioplayers` out of
/// notifiers so tests can inject a fake that fires completion deterministically.
abstract interface class AudioPlayback {
  /// Plays the audio, calling [onComplete] when it finishes.
  ///
  /// When [bytes] and [uri] are both null (metadata-only / mock assets) it
  /// falls back to a [Timer] after [simulatedDuration] so the workflow still
  /// advances offline.
  void start({
    Uint8List? bytes,
    Uri? uri,
    required Duration simulatedDuration,
    required void Function() onComplete,
  });

  /// Stops any active playback / pending scheduled completion.
  void cancel();
}

/// Production playback backed by `audioplayers`.
final class AudioplayersBackedPlayback implements AudioPlayback {
  audio.AudioPlayer? _engine;
  StreamSubscription<void>? _completionSub;
  Timer? _fallbackTimer;

  @override
  void start({
    Uint8List? bytes,
    Uri? uri,
    required Duration simulatedDuration,
    required void Function() onComplete,
  }) {
    cancel();

    if (bytes == null && uri == null) {
      _fallbackTimer = Timer(simulatedDuration, onComplete);
      return;
    }

    final engine = _engine ??= audio.AudioPlayer();
    _completionSub = engine.onPlayerComplete.listen((_) => onComplete());

    if (bytes != null) {
      unawaited(engine.play(audio.BytesSource(bytes)));
    } else {
      unawaited(engine.play(audio.UrlSource(uri!.toString())));
    }
  }

  @override
  void cancel() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    _completionSub?.cancel();
    _completionSub = null;
    // Best-effort stop; the engine lives for the app session (same as the
    // editor player) and is disposed only by the notifier lifecycle.
    unawaited(_engine?.stop());
  }

  /// Releases the underlying player. Call from the owner's dispose.
  Future<void> dispose() async {
    await _completionSub?.cancel();
    _completionSub = null;
    await _engine?.dispose();
    _engine = null;
  }
}