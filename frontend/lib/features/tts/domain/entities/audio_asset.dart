import 'dart:typed_data';

/// A generated or simulated audio asset.
///
/// Domain-level representation of audio. The asset may carry either raw
/// [bytes] (the download path) and/or a streamable [uri] (the stream path).
/// When both are null the asset is metadata-only (unplayable) — the mock uses
/// this shape.
final class AudioAsset {
  const AudioAsset({
    required this.id,
    required this.duration,
    required this.format,
    required this.kind,
    this.bytes,
    this.uri,
  });

  final AudioAssetId id;
  final Duration duration;
  final AudioFormat format;
  final AudioKind kind;

  /// Raw WAV data (download path). Null when the asset carries no audio.
  final Uint8List? bytes;

  /// Streamable URL for the audio (stream path). Null when not available.
  final Uri? uri;
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
