import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/data/repositories/mock_tts_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

void main() {
  const chitwan = VoiceProfile(
    id: 'chitwan',
    language: VoiceLanguage.nepali,
    label: 'Chitwan',
  );
  const unknownVoice = VoiceProfile(
    id: 'unknown',
    language: VoiceLanguage.nepali,
    label: 'Unknown',
  );

  group('MockTtsRepository', () {
    test('generates a clean audio asset for a valid request', () async {
      final repository = MockTtsRepository();
      final result = await repository.generateAudio(
        const TtsRequest(text: 'देब्रे मोड्नुहोस्।', language: VoiceLanguage.nepali, voice: chitwan),
      );

      expect(result.isOk, isTrue);
      final asset = (result as Ok<AudioAsset>).value;
      expect(asset.kind, AudioKind.clean);
      expect(asset.format, AudioFormat.wav);
      expect(asset.duration.inMilliseconds, greaterThan(0));
      expect(asset.id.value, contains('audio'));
    });

    test('returns TtsGenerationFailure for an unavailable voice', () async {
      final repository = MockTtsRepository();
      final result = await repository.generateAudio(
        const TtsRequest(text: 'देब्रे मोड्नुहोस्।', language: VoiceLanguage.nepali, voice: unknownVoice),
      );

      expect(result.isErr, isTrue);
    });

    test('returns TtsGenerationFailure for empty text', () async {
      final repository = MockTtsRepository();
      final result = await repository.generateAudio(
        const TtsRequest(text: '  ', language: VoiceLanguage.nepali, voice: chitwan),
      );

      expect(result.isErr, isTrue);
    });
  });
}
