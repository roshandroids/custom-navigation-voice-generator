import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';

/// A suggested custom instruction.
final class Suggestion {
  const Suggestion({
    required this.text,
    required this.personality,
    required this.language,
  });

  final String text;
  final Personality personality;
  final VoiceLanguage language;
}

/// A request for suggestion generation.
final class SuggestionRequest {
  const SuggestionRequest({
    required this.situation,
    required this.standardText,
    required this.personality,
    required this.language,
  });

  final String situation;
  final String standardText;
  final Personality personality;
  final VoiceLanguage language;
}

/// Contract for generating personalized instruction suggestions.
///
/// The MVP uses a mock implementation with a local template pool; a future
/// implementation may call a language model or heuristic service.
abstract interface class SuggestionRepository {
  Future<Result<List<Suggestion>>> generate(SuggestionRequest request);
}
