import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/data/repositories/mock_suggestion_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

void main() {
  group('MockSuggestionRepository', () {
    test('generates suggestions matching the request personality and language', () async {
      final repository = MockSuggestionRepository();
      final result = await repository.generate(
        const SuggestionRequest(
          situation: 'स्पिड क्यामेरा',
          standardText: 'अगाडि स्पिड क्यामेरा छ।',
          personality: Personality.savage,
          language: VoiceLanguage.nepali,
        ),
      );

      expect(result.isOk, isTrue);
      final suggestions = (result as Ok<List<Suggestion>>).value;
      expect(suggestions, isNotEmpty);
      for (final suggestion in suggestions) {
        expect(suggestion.personality, Personality.savage);
        expect(suggestion.language, VoiceLanguage.nepali);
      }
    });

    test('returns at least one suggestion per category for English normal', () async {
      final repository = MockSuggestionRepository();
      final result = await repository.generate(
        const SuggestionRequest(
          situation: 'Speed camera',
          standardText: 'Speed camera ahead.',
          personality: Personality.normal,
          language: VoiceLanguage.english,
        ),
      );

      expect(result.isOk, isTrue);
      expect((result as Ok<List<Suggestion>>).value, isNotEmpty);
    });
  });
}
