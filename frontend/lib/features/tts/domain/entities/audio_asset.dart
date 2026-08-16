/// A generated or simulated audio asset.
///
/// Domain-level representation of audio: the frontend does not ship real
/// audio for the MVP, so assets are metadata-only and playback is simulated.
final class AudioAsset {
  const AudioAsset({
    required this.id,
    required this.duration,
    required this.format,
    required this.kind,
  });

  final AudioAssetId id;
  final Duration duration;
  final AudioFormat format;
  final AudioKind kind;
}

final class AudioAssetId {
  const AudioAssetId(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is AudioAssetId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'AudioAssetId($value)';
}

/// Audio container format. The benchmark standard is WAV 16 kHz mono PCM.
enum AudioFormat {
  wav('WAV');

  const AudioFormat(this.label);

  final String label;
}

/// What the audio contains.
enum AudioKind {
  /// Voice only — the generated TTS output.
  clean('Clean'),

  /// Conceptually: silence + voice + silence, ready to record into Waze.
  ///
  /// The MVP only simulates this; no recording-ready audio is generated yet.
  recordingReady('Recording ready');

  const AudioKind(this.label);

  final String label;
}
