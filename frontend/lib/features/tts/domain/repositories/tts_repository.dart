import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// A request to synthesize speech for an instruction.
final class TtsRequest {
  const TtsRequest({
    required this.text,
    required this.language,
    required this.voice,
  });

  final String text;
  final VoiceLanguage language;
  final VoiceProfile voice;
}

/// Contract for text-to-speech generation.
///
/// The domain does not know whether the implementation is a mock, an HTTP
/// client, FastAPI, or Piper — swapping the implementation only changes the
/// data layer and the DI wiring.
abstract interface class TtsRepository {
  Future<Result<AudioAsset>> generateAudio(TtsRequest request);
}
