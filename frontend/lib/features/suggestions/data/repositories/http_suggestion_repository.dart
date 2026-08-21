import 'package:dio/dio.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// HTTP suggestion repository backed by the FastAPI service via `dio`
/// (`POST /v1/suggestions`). The server ports the app's curated template pool.
class HttpSuggestionRepository implements SuggestionRepository {
  HttpSuggestionRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Result<List<Suggestion>>> generate(SuggestionRequest request) async {
    try {
      final response = await _dio.post<void>(
        '/v1/suggestions',
        data: {
          'situation': request.situation,
          'standardText': request.standardText,
          'personality': request.personality.name,
          'language': request.language.code,
        },
      );
      final items = response.data as List<dynamic>;
      return Ok([
        for (final item in items.cast<Map<String, dynamic>>())
          _suggestionFromJson(item),
      ]);
    } on DioException catch (error) {
      return Err(
        SuggestionFailure(
          'Could not generate suggestions (${error.response?.statusCode ?? 'network'}).',
        ),
      );
    }
  }
}

Suggestion _suggestionFromJson(Map<String, dynamic> json) => Suggestion(
      text: json['text'] as String,
      personality: Personality.values.firstWhere(
        (p) => p.name == json['personality'],
        orElse: () => Personality.normal,
      ),
      language: VoiceLanguage.fromCode(json['language'] as String),
    );