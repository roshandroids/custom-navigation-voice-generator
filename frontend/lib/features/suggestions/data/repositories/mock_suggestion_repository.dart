import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// Mock suggestion generator with a small local template pool.
///
/// Suggestions follow the voice pack's language and personality. This is the
/// swap point for a future model/heuristic-backed implementation.
class MockSuggestionRepository implements SuggestionRepository {
  MockSuggestionRepository({
    this.generationDelay = const Duration(milliseconds: 300),
  });

  final Duration generationDelay;

  @override
  Future<Result<List<Suggestion>>> generate(SuggestionRequest request) async {
    await Future<void>.delayed(generationDelay);
    return Ok(_suggestionsFor(request));
  }

  List<Suggestion> _suggestionsFor(SuggestionRequest request) {
    final trimmedStandard = request.standardText.trim();
    final base = <String>[
      trimmedStandard,
      '${request.situation.trim()} — $trimmedStandard',
    ];

    final personalitySuffix = switch (request.personality) {
      Personality.simple => request.language == VoiceLanguage.nepali
          ? 'भो, अब देब्रे।'
          : 'Okay, left it is.',
      Personality.normal => request.language == VoiceLanguage.nepali
          ? 'कृपया देब्रेतिर लाग्नुहोस्।'
          : 'Please keep left.',
      Personality.firm => request.language == VoiceLanguage.nepali
          ? 'ल, अब देब्रे मोड्नुहोस्।'
          : 'Now turn left, watch your speed.',
      Personality.savage => request.language == VoiceLanguage.nepali
          ? 'फेरि देब्रे? ल, जाऔँ।'
          : 'Left again? Fine, let\'s go.',
    };

    return [
      Suggestion(
        text: '${request.standardText.trim()} $personalitySuffix',
        personality: request.personality,
        language: request.language,
      ),
      Suggestion(
        text: base[1],
        personality: request.personality,
        language: request.language,
      ),
    ];
  }
}
