import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';

/// HTTP TTS repository: Flutter → FastAPI `/v1/synthesize` → Piper.
///
/// Swaps into the [TtsRepository] contract in place of [MockTtsRepository]:
/// screens, use cases and business rules do not change.
///
/// The service returns raw WAV bytes (download path) plus an `X-Audio-Url`
/// header for the stream path; both are surfaced on the returned
/// [AudioAsset] ([AudioAsset.bytes] and [AudioAsset.uri]).
class HttpTtsRepository implements TtsRepository {
  HttpTtsRepository({
    required this.baseUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : _client = client ?? http.Client();

  /// Base origin of the TTS service, e.g. `http://127.0.0.1:8000`.
  final Uri baseUri;

  final Duration timeout;

  final http.Client _client;

  @override
  Future<Result<AudioAsset>> generateAudio(TtsRequest request) async {
    if (request.text.trim().isEmpty) {
      return const Err(TtsGenerationFailure('Cannot generate audio for empty text.'));
    }

    final uri = baseUri.resolve('/v1/synthesize');
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': request.text,
              'voice': request.voice.id,
              'language': request.language.code,
            }),
          )
          .timeout(timeout);
    } catch (error) {
      return Err(
        TtsGenerationFailure('Could not reach the TTS service: $error'),
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Err(
        TtsGenerationFailure(
          'TTS service returned ${response.statusCode}.',
        ),
      );
    }

    final bytes = Uint8List.fromList(response.bodyBytes);
    final durationMs = int.tryParse(
      response.headers['x-audio-duration'] ?? '',
    );
    final urlPath = response.headers['x-audio-url'];
    final uri_ = urlPath == null ? null : baseUri.resolve(urlPath);

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
  if (bytes.length < 44 || bytes[0] != 0x52) return 0; // "R" in "RIFF"
  final sampleRate = ByteData.sublistView(bytes).getUint32(24, Endian.little);
  final byteRate = ByteData.sublistView(bytes).getUint32(28, Endian.little);
  final dataSize =
      ByteData.sublistView(bytes).getUint32(40, Endian.little);
  if (sampleRate == 0 || byteRate == 0) return 0;
  return ((dataSize / byteRate) * 1000).round();
}