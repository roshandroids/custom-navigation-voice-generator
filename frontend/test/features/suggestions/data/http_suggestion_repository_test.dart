import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/suggestions/data/repositories/http_suggestion_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

final _baseUrl = 'http://127.0.0.1:8000';

(Dio, DioAdapter) _mockedDio() {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

void main() {
  test('generate posts the request and maps suggestions', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/suggestions',
      (server) => server.reply(200, [
        {
          'text': 'देब्रे मोड्नुहोस्। फेरि देब्रे? ल, जाऔँ।',
          'personality': 'savage',
          'language': 'ne',
        },
        {
          'text': 'बायाँ मोड — देब्रे मोड्नुहोस्।',
          'personality': 'savage',
          'language': 'ne',
        },
      ]),
      data: {
        'situation': 'बायाँ मोड',
        'standardText': 'देब्रे मोड्नुहोस्।',
        'personality': 'savage',
        'language': 'ne',
      },
    );
    final repo = HttpSuggestionRepository(dio: dio);

    final result = await repo.generate(
      const SuggestionRequest(
        situation: 'बायाँ मोड',
        standardText: 'देब्रे मोड्नुहोस्।',
        personality: Personality.savage,
        language: VoiceLanguage.nepali,
      ),
    );
    expect(result.isOk, isTrue);
    final suggestions = (result as Ok<List<Suggestion>>).value;
    expect(suggestions.length, 2);
    expect(suggestions.first.text, contains('फेरि देब्रे'));
    expect(suggestions.first.personality, Personality.savage);
  });

  test('server error maps to a SuggestionFailure', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost('/v1/suggestions', (server) => server.reply(400, {'detail': 'bad'}));
    final repo = HttpSuggestionRepository(dio: dio);

    final result = await repo.generate(
      const SuggestionRequest(
        situation: 'x',
        standardText: 'y',
        personality: Personality.normal,
        language: VoiceLanguage.english,
      ),
    );
    expect(result.isErr, isTrue);
  });
}