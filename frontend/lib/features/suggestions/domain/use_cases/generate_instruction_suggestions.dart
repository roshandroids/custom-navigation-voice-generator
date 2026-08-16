import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// Generates personalized instruction suggestions for a situation.
class GenerateInstructionSuggestions {
  const GenerateInstructionSuggestions(this._repository);

  final SuggestionRepository _repository;

  Future<Result<List<Suggestion>>> execute({
    required String situation,
    required String standardText,
    required Personality personality,
    required VoiceLanguage language,
  }) =>
      _repository.generate(
        SuggestionRequest(
          situation: situation,
          standardText: standardText,
          personality: personality,
          language: language,
        ),
      );
}
