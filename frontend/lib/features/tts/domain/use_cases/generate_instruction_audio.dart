import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// Synthesizes speech for an instruction's custom text.
///
/// Depends on [TtsRepository] — the domain never knows whether the
/// implementation is a mock, HTTP, FastAPI, or Piper.
class GenerateInstructionAudio {
  const GenerateInstructionAudio(this._repository);

  final TtsRepository _repository;

  Future<Result<AudioAsset>> execute({
    required String text,
    required VoiceLanguage language,
    required VoiceProfile voice,
  }) {
    if (text.trim().isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Cannot generate audio for empty text.')),
      );
    }
    return _repository.generateAudio(
      TtsRequest(text: text, language: language, voice: voice),
    );
  }
}
