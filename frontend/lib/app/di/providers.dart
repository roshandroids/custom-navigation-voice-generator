import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/core/config/app_config.dart';
import 'package:navigation_voice_generator/features/export/data/repositories/http_export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';
import 'package:navigation_voice_generator/features/instructions/data/repositories/http_instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/data/repositories/http_suggestion_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/tts/data/repositories/http_tts_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/data/repositories/http_voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';

/// Dependency injection wiring.
///
/// Presentation never constructs repositories: it depends on these providers,
/// which implement domain contracts. All data sources are API-backed by the
/// FastAPI TTS service (voice packs, instructions, suggestions, TTS, export).
/// Tests override the repo providers (or [dioProvider]) with fakes/mocks.
final class Di {
  Di._();
}

/// Shared HTTP client for the FastAPI service, using `dio`. Overridable in
/// tests (e.g. with `http_mock_adapter`).
final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
});

/// Voice packs, seeded server-side and persisted there.
final voicePackRepositoryProvider = Provider<VoicePackRepository>((ref) {
  return HttpVoicePackRepository(dio: ref.watch(dioProvider));
});

/// Instructions, seeded server-side and persisted there.
final instructionRepositoryProvider = Provider<InstructionRepository>((ref) {
  return HttpInstructionRepository(dio: ref.watch(dioProvider));
});

/// Real TTS: the FastAPI service (Flutter → FastAPI → Piper).
final ttsRepositoryProvider = Provider<TtsRepository>((ref) {
  return HttpTtsRepository(dio: ref.watch(dioProvider));
});

/// Suggestion generation, computed server-side.
final suggestionRepositoryProvider = Provider<SuggestionRepository>((ref) {
  return HttpSuggestionRepository(dio: ref.watch(dioProvider));
});

/// Export bundle assembly, performed server-side.
final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return HttpExportRepository(dio: ref.watch(dioProvider));
});