import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/data/repositories/http_tts_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

const _chitwan = VoiceProfile(
  id: 'chitwan',
  language: VoiceLanguage.nepali,
  label: 'Chitwan',
);

const _baseUrl = 'http://127.0.0.1:8000';

// A tiny valid WAV payload (1-second 22050 Hz mono PCM16 track).
const String _wavHeader =
    'RIFF????WAVEfmt \x10\x00\x00\x00\x01\x00\x01\x00'
    '\x22\x56\x00\x00' // sample rate 22050
    '\x44\xac\x00\x00' // byte rate 44100
    '\x02\x00\x10\x00' // block align, bits per sample
    'data\x44\xac\x00\x00'; // data size 44100
// (The '????' file-size field is ignored by the duration fallback.)
final Uint8List _wavBytes = Uint8List.fromList(_wavHeader.codeUnits);

const _audioUrlPath = '/v1/audio/chitwan__abc123.wav';

(Dio, DioAdapter) _mockedDio() {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final adapter = DioAdapter(dio: dio);
  return (dio, adapter);
}

void main() {
  test('generates audio and populates bytes and uri on success', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/synthesize',
      (server) => server.reply(
        200,
        _wavBytes,
        headers: {
          'content-type': ['audio/wav'],
          'x-audio-duration': ['1000'],
          'x-audio-sample-rate': ['22050'],
          'x-audio-voice': ['chitwan'],
          'x-audio-url': [_audioUrlPath],
        },
      ),
      data: {
        'text': 'देब्रे मोड्नुहोस्।',
        'voice': 'chitwan',
        'language': 'ne',
      },
    );
    final repository = HttpTtsRepository(dio: dio);

    final result = await repository.generateAudio(
      const TtsRequest(
        text: 'देब्रे मोड्नुहोस्।',
        language: VoiceLanguage.nepali,
        voice: _chitwan,
      ),
    );

    expect(result.isOk, isTrue);
    final asset = (result as Ok<AudioAsset>).value;
    expect(asset.kind, AudioKind.clean);
    expect(asset.format, AudioFormat.wav);
    expect(asset.duration, const Duration(seconds: 1));
    expect(asset.bytes, _wavBytes);
    expect(asset.uri, Uri.parse('http://127.0.0.1:8000$_audioUrlPath'));
  });

  test('derives duration from the WAV header when header is missing', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/synthesize',
      (server) =>
          server.reply(200, _wavBytes, headers: {'content-type': ['audio/wav']}),
      data: {'text': 'Turn left', 'voice': 'joe', 'language': 'en'},
    );
    final repository = HttpTtsRepository(dio: dio);

    final result = await repository.generateAudio(
      TtsRequest(
        text: 'Turn left',
        language: VoiceLanguage.english,
        voice: const VoiceProfile(id: 'joe', language: VoiceLanguage.english, label: 'Joe'),
      ),
    );

    expect(result.isOk, isTrue);
    final asset = (result as Ok<AudioAsset>).value;
    // 44100 bytes / 44100 bytes-per-second = 1.0s.
    expect(asset.duration, const Duration(seconds: 1));
  });

  test('returns TtsGenerationFailure on non-2xx response', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/synthesize',
      (server) => server.reply(500, {'detail': 'boom'}),
      data: {'text': 'hi', 'voice': 'chitwan', 'language': 'ne'},
    );
    final repository = HttpTtsRepository(dio: dio);

    final result = await repository.generateAudio(
      const TtsRequest(text: 'hi', language: VoiceLanguage.nepali, voice: _chitwan),
    );
    expect(result.isErr, isTrue);
    expect((result as Err<AudioAsset>).failure, isA<TtsGenerationFailure>());
  });

  test('returns TtsGenerationFailure on network error', () async {
    final (dio, adapter) = _mockedDio();
    adapter.onPost(
      '/v1/synthesize',
      (server) => server.throws(
        0,
        DioException(
          requestOptions: RequestOptions(path: '/v1/synthesize'),
          type: DioExceptionType.connectionError,
        ),
      ),
      data: {'text': 'hi', 'voice': 'chitwan', 'language': 'ne'},
    );
    final repository = HttpTtsRepository(dio: dio);

    final result = await repository.generateAudio(
      const TtsRequest(text: 'hi', language: VoiceLanguage.nepali, voice: _chitwan),
    );
    expect(result.isErr, isTrue);
    expect((result as Err<AudioAsset>).failure, isA<TtsGenerationFailure>());
  });

  test('returns TtsGenerationFailure for empty text without a request', () async {
    final (dio, _) = _mockedDio();
    final repository = HttpTtsRepository(dio: dio);

    final result = await repository.generateAudio(
      const TtsRequest(text: '   ', language: VoiceLanguage.nepali, voice: _chitwan),
    );
    expect(result.isErr, isTrue);
  });
}