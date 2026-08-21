import 'package:dio/dio.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// HTTP instruction repository backed by the FastAPI service via `dio`.
class HttpInstructionRepository implements InstructionRepository {
  HttpInstructionRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  String get _baseUrl => _dio.options.baseUrl;
  String _instrPath(VoicePackId packId, InstructionId id) =>
      '/v1/voice-packs/${packId.value}/instructions/${id.value}';

  Failure _failureFor(DioException error) {
    final status = error.response?.statusCode;
    if (status == 404) return const NotFoundFailure('Instruction not found.');
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return const RepositoryFailure('Could not reach the service.');
    }
    return RepositoryFailure('Request failed (${status ?? 'network'}).');
  }

  @override
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId) async {
    try {
      final response = await _dio.get<void>(
        '/v1/voice-packs/${packId.value}/instructions',
      );
      final items = response.data as List<dynamic>;
      return Ok([
        for (final item in items)
          _instructionFromJson(_baseUrl, packId, item as Map<String, dynamic>),
      ]);
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }

  @override
  Future<Result<Instruction>> getById(VoicePackId packId, InstructionId id) async {
    return _instructionCall(() => _dio.get<void>(_instrPath(packId, id)), packId);
  }

  @override
  Future<Result<Instruction>> updateCustomText({
    required VoicePackId packId,
    required InstructionId id,
    required String text,
  }) async {
    return _instructionCall(
      () => _dio.patch<void>(_instrPath(packId, id), data: {'customText': text}),
      packId,
    );
  }

  @override
  Future<Result<Instruction>> attachAudio({
    required VoicePackId packId,
    required InstructionId id,
    required AudioAsset audio,
  }) async {
    return _instructionCall(
      () => _dio.put<void>(
        '${_instrPath(packId, id)}/audio',
        data: {'audioUrl': audio.uri?.toString() ?? ''},
      ),
      packId,
    );
  }

  @override
  Future<Result<Instruction>> markRecorded({
    required VoicePackId packId,
    required InstructionId id,
  }) async {
    return _instructionCall(
      () => _dio.patch<void>(_instrPath(packId, id), data: {'isRecorded': true}),
      packId,
    );
  }

  Future<Result<Instruction>> _instructionCall(
    Future<Response<void>> Function() request,
    VoicePackId packId,
  ) async {
    try {
      final response = await request();
      return Ok(
        _instructionFromJson(_baseUrl, packId, response.data as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }

  @override
  Future<Result<int>> countForPack(VoicePackId packId) async {
    return _progressFor(packId, (p) => p['total'] as int);
  }

  @override
  Future<Result<int>> countRecordedForPack(VoicePackId packId) async {
    return _progressFor(packId, (p) => p['recorded'] as int);
  }

  Future<Result<int>> _progressFor(
    VoicePackId packId,
    int Function(Map<String, dynamic>) pick,
  ) async {
    try {
      final response = await _dio.get<void>(
        '/v1/voice-packs/${packId.value}/progress',
      );
      return Ok(pick(response.data as Map<String, dynamic>));
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }
}

Instruction _instructionFromJson(
  String baseUrl,
  VoicePackId packId,
  Map<String, dynamic> json,
) {
  final audioUrl = json['audioUrl'] as String?;
  return Instruction(
    id: InstructionId(json['id'] as String),
    packId: packId,
    category: InstructionCategory.fromCorpus(json['category'] as String) ??
        InstructionCategory.directions,
    situation: json['situation'] as String,
    standardText: json['standardText'] as String,
    customText: json['customText'] as String,
    audio: audioUrl == null
        ? null
        : AudioAsset(
            id: AudioAssetId('audio-$audioUrl'),
            duration: Duration.zero,
            format: AudioFormat.wav,
            kind: AudioKind.clean,
            uri: Uri.parse('$baseUrl$audioUrl'),
          ),
    isRecorded: json['isRecorded'] as bool? ?? false,
  );
}