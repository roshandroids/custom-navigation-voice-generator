import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';

/// HTTP TTS repository: Flutter → FastAPI `/v1/synthesize` → Piper, via `dio`.
///
/// Swaps into the [TtsRepository] contract in place of [MockTtsRepository]:
/// screens, use cases and business rules do not change.
///
/// The service returns raw WAV bytes (download path) plus an `X-Audio-Url`
/// header for the stream path; both are surfaced on the returned
/// [AudioAsset] ([AudioAsset.bytes] and [AudioAsset.uri]).
class HttpTtsRepository implements TtsRepository {
  HttpTtsRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Result<AudioAsset>> generateAudio(TtsRequest request) async {
    if (request.text.trim().isEmpty) {
      return const Err(TtsGenerationFailure('Cannot generate audio for empty text.'));
    }

    final Response<List<int>> response;
    try {
      response = await _dio.post<List<int>>(
        '/v1/synthesize',
        data: {
          'text': request.text,
          'voice': request.voice.id,
          'language': request.language.code,
        },
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (error) {
      return Err(
        TtsGenerationFailure(
          'Could not reach the TTS service '
          '(${error.response?.statusCode ?? 'network'}).',
        ),
      );
    }

    final bytes = Uint8List.fromList(response.data ?? const []);
    if (bytes.isEmpty) {
      return const Err(TtsGenerationFailure('TTS service returned no audio.'));
    }

    final headers = response.headers;
    final durationMs = int.tryParse(headers.value('x-audio-duration') ?? '');
    final urlPath = headers.value('x-audio-url');
    final uri_ = urlPath == null
        ? null
        : Uri.parse('${_dio.options.baseUrl}$urlPath');

    return Ok(
      AudioAsset(
        id: AudioAssetId(
          'audio-${request.language.name}-${request.voice.id}-${DateTime.now().microsecondsSinceEpoch}',
        ),
        duration: Duration(
          milliseconds: durationMs ?? _estimateDurationFromBytes(bytes),
        ),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
        bytes: bytes,
        uri: uri_,
      ),
    );
  }
}

/// Fallback: parse duration from a WAV's header (44-byte RIFF header, byte
/// offset 28 = sample rate, offset 40 = data byte count). Returns null-ish 0
/// if the payload is not a WAV.
int _estimateDurationFromBytes(Uint8List bytes) {
  if (bytes.isEmpty) return 0;
  if (bytes.length < 44 || bytes[0] != 0x52) return 0; // "R" in "RIFF"
  final view = ByteData.sublistView(bytes);
  final sampleRate = view.getUint32(24, Endian.little);
  final byteRate = view.getUint32(28, Endian.little);
  final dataSize = view.getUint32(40, Endian.little); // sub-chunk-2 size
  if (sampleRate == 0 || byteRate == 0) return 0;
  return ((dataSize / byteRate) * 1000).round();
}