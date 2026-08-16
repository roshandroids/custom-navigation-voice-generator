import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';

void main() {
  group('AudioAsset', () {
    test('creates a clean audio asset', () {
      const asset = AudioAsset(
        id: AudioAssetId('audio-1'),
        duration: Duration(seconds: 4),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      );
      expect(asset.id.value, 'audio-1');
      expect(asset.duration, const Duration(seconds: 4));
      expect(asset.format, AudioFormat.wav);
      expect(asset.kind, AudioKind.clean);
    });

    test('distinguishes clean from recording-ready audio', () {
      const clean = AudioAsset(
        id: AudioAssetId('a'),
        duration: Duration(seconds: 3),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      );
      const ready = AudioAsset(
        id: AudioAssetId('b'),
        duration: Duration(seconds: 7),
        format: AudioFormat.wav,
        kind: AudioKind.recordingReady,
      );
      expect(clean.kind, AudioKind.clean);
      expect(ready.kind, AudioKind.recordingReady);
      expect(ready.duration, const Duration(seconds: 7));
    });
  });
}
