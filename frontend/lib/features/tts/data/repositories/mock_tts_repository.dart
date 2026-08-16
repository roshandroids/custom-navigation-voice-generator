import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';

/// Mock TTS: simulates generation with a short delay and returns audio
/// metadata proportional to the text length.
///
/// This is the swap point for the future [HttpTtsRepository] (Flutter →
/// FastAPI → Piper): screens, domain entities, use cases and business rules
/// do not change, only this implementation and the DI wiring.
class MockTtsRepository implements TtsRepository {
  MockTtsRepository({this.generationDelay = const Duration(milliseconds: 350)});

  /// Simulated generation time. Tests can set this to zero.
  final Duration generationDelay;

  static const _knownVoiceIds = {
    'chitwan',
    'google-medium',
    'google-x-low',
    'joe',
    'kristin',
    'ljspeech',
  };

  @override
  Future<Result<AudioAsset>> generateAudio(TtsRequest request) async {
    if (request.text.trim().isEmpty) {
      return const Err(TtsGenerationFailure('Cannot generate audio for empty text.'));
    }
    if (!_knownVoiceIds.contains(request.voice.id)) {
      return Err(
        TtsGenerationFailure('Voice "${request.voice.id}" is not available.'),
      );
    }

    await Future<void>.delayed(generationDelay);

    // Roughly 0.28s per word, clamped to a plausible range.
    final words = request.text.trim().split(RegExp(r'\s+')).length;
    final seconds = (words * 0.28).clamp(0.8, 12.0);
    final id = 'audio-${request.language.name}-${request.voice.id}-${DateTime.now().microsecondsSinceEpoch}';

    return Ok(
      AudioAsset(
        id: AudioAssetId(id),
        duration: Duration(milliseconds: (seconds * 1000).round()),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      ),
    );
  }
}
