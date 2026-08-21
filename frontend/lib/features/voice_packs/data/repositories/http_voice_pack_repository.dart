import 'package:dio/dio.dart';

import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// HTTP voice pack repository backed by the FastAPI service via `dio`
/// (`GET/POST /v1/voice-packs`). Returns the server-assigned pack on create.
class HttpVoicePackRepository implements VoicePackRepository {
  HttpVoicePackRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Failure _failureFor(DioException error) {
    final status = error.response?.statusCode;
    if (status == 404) return const NotFoundFailure('Voice pack not found.');
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return const RepositoryFailure('Could not reach the service.');
    }
    return RepositoryFailure('Request failed (${status ?? 'network'}).');
  }

  @override
  Future<Result<VoicePack>> create(VoicePack voice) async {
    try {
      final response = await _dio.post<void>(
        '/v1/voice-packs',
        data: {
          'name': voice.name.value,
          'language': voice.language.code,
          'voice': voice.voice.id,
          'personality': voice.personality.name,
        },
      );
      return Ok(_packFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }

  @override
  Future<Result<VoicePack>> getById(VoicePackId id) async {
    try {
      final response = await _dio.get<void>('/v1/voice-packs/${id.value}');
      return Ok(_packFromJson(response.data as Map<String, dynamic>));
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }

  @override
  Future<Result<List<VoicePack>>> getAll() async {
    try {
      final response = await _dio.get<void>('/v1/voice-packs');
      final items = response.data as List<dynamic>;
      return Ok([
        for (final item in items) _packFromJson(item as Map<String, dynamic>),
      ]);
    } on DioException catch (error) {
      return Err(_failureFor(error));
    }
  }
}

VoicePack _packFromJson(Map<String, dynamic> json) {
  final nameResult = VoicePackName.create(json['name'] as String);
  final name = (nameResult as Ok<VoicePackName>).value;
  return VoicePack(
    id: VoicePackId(json['id'] as String),
    name: name,
    language: VoiceLanguage.fromCode(json['language'] as String),
    voice: _voice(json),
    personality: _personality(json['personality'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

VoiceProfile _voice(Map<String, dynamic> json) {
  final id = json['voice'] as String;
  final language = VoiceLanguage.fromCode(json['language'] as String);
  return VoiceCatalog.byId(id) ??
      VoiceProfile(id: id, language: language, label: id);
}

Personality _personality(String value) => Personality.values.firstWhere(
      (p) => p.name == value,
      orElse: () => Personality.normal,
    );