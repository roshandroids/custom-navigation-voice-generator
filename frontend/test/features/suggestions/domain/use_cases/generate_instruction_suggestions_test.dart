import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/use_cases/generate_instruction_suggestions.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

class FakeSuggestionRepository implements SuggestionRepository {
  Failure? failure;
  SuggestionRequest? lastRequest;

  @override
  Future<Result<List<Suggestion>>> generate(SuggestionRequest request) async {
    lastRequest = request;
    if (failure != null) return Err(failure!);
    return Ok([
      Suggestion(
        text: 'Suggestion for ${request.situation}',
        personality: request.personality,
        language: request.language,
      ),
    ]);
  }
}

void main() {
  group('GenerateInstructionSuggestions', () {
    test('generates suggestions for a valid request', () async {
      final repository = FakeSuggestionRepository();
      final useCase = GenerateInstructionSuggestions(repository);

      final result = await useCase.execute(
        situation: 'बायाँ मोड',
        standardText: 'देब्रे मोड्नुहोस्।',
        personality: Personality.savage,
        language: VoiceLanguage.nepali,
      );

      expect(result.isOk, isTrue);
      final suggestions = (result as Ok<List<Suggestion>>).value;
      expect(suggestions, hasLength(1));
      expect(suggestions.first.text, contains('बायाँ मोड'));
      expect(repository.lastRequest?.personality, Personality.savage);
      expect(repository.lastRequest?.language, VoiceLanguage.nepali);
    });

    test('propagates repository failure', () async {
      final repository = FakeSuggestionRepository()
        ..failure = const SuggestionFailure('suggestion service down');
      final result = await GenerateInstructionSuggestions(repository).execute(
        situation: 'बायाँ मोड',
        standardText: 'देब्रे मोड्नुहोस्।',
        personality: Personality.savage,
        language: VoiceLanguage.nepali,
      );

      expect(result.isErr, isTrue);
      expect((result as Err<List<Suggestion>>).failure, isA<SuggestionFailure>());
    });
  });
}
