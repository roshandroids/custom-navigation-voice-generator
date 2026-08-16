import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/use_cases/generate_instruction_audio.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

class FakeTtsRepository implements TtsRepository {
  Failure? failure;
  TtsRequest? lastRequest;

  @override
  Future<Result<AudioAsset>> generateAudio(TtsRequest request) async {
    lastRequest = request;
    if (failure != null) return Err(failure!);
    return const Ok(
      AudioAsset(
        id: AudioAssetId('audio-1'),
        duration: Duration(seconds: 4),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      ),
    );
  }
}

void main() {
  const voice = VoiceProfile(
    id: 'chitwan',
    language: VoiceLanguage.nepali,
    label: 'Chitwan',
  );

  group('GenerateInstructionAudio', () {
    test('generates audio for a valid request', () async {
      final repository = FakeTtsRepository();
      final useCase = GenerateInstructionAudio(repository);

      final result = await useCase.execute(
        text: 'देब्रे मोड्नुहोस्।',
        language: VoiceLanguage.nepali,
        voice: voice,
      );

      expect(result.isOk, isTrue);
      final asset = (result as Ok<AudioAsset>).value;
      expect(asset.kind, AudioKind.clean);
      expect(asset.format, AudioFormat.wav);
      expect(repository.lastRequest?.text, 'देब्रे मोड्नुहोस्।');
      expect(repository.lastRequest?.voice, voice);
    });

    test('rejects empty text with ValidationFailure', () async {
      final result = await GenerateInstructionAudio(FakeTtsRepository()).execute(
        text: '   ',
        language: VoiceLanguage.nepali,
        voice: voice,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<AudioAsset>).failure, isA<ValidationFailure>());
    });

    test('propagates repository failure', () async {
      final repository = FakeTtsRepository()
        ..failure = const TtsGenerationFailure('engine down');
      final result = await GenerateInstructionAudio(repository).execute(
        text: 'देब्रे मोड्नुहोस्।',
        language: VoiceLanguage.nepali,
        voice: voice,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<AudioAsset>).failure, isA<TtsGenerationFailure>());
    });
  });
}
