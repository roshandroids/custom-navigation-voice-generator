import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/core/config/app_config.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/data/repositories/mock_export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';
import 'package:navigation_voice_generator/features/instructions/data/repositories/in_memory_instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/data/repositories/mock_suggestion_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';
import 'package:navigation_voice_generator/features/tts/data/repositories/http_tts_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/data/repositories/in_memory_voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// Dependency injection wiring.
///
/// Presentation never constructs repositories: it depends on these providers,
/// which implement domain contracts. Swapping the mock TTS for the future
/// HTTP implementation only changes the [ttsRepositoryProvider] override.
final class Di {
  Di._();
}

/// Voice packs are stored in a single shared in-memory repository instance
/// for the app session (not per-widget). Pre-seeded with a Nepali and an
/// English sample pack matching the seeded instruction packs (`seed-ne` /
/// `seed-en`) so the app demos end-to-end without Python.
final voicePackRepositoryProvider = Provider<VoicePackRepository>((ref) {
  final repository = InMemoryVoicePackRepository();
  repository.create(
    VoicePack(
      id: const VoicePackId('seed-ne'),
      name: (VoicePackName.create('My Nepali Voice') as Ok<VoicePackName>).value,
      language: VoiceLanguage.nepali,
      voice: VoiceCatalog.nepali.first,
      personality: Personality.savage,
      createdAt: DateTime(2026, 8, 15),
    ),
  );
  repository.create(
    VoicePack(
      id: const VoicePackId('seed-en'),
      name: (VoicePackName.create('English Daily') as Ok<VoicePackName>).value,
      language: VoiceLanguage.english,
      voice: VoiceCatalog.english.first,
      personality: Personality.normal,
      createdAt: DateTime(2026, 8, 14),
    ),
  );
  return repository;
});

/// Instructions are seeded once and shared app-wide.
final instructionRepositoryProvider = Provider<InstructionRepository>((ref) {
  return InMemoryInstructionRepository.seeded();
});

/// Real TTS: the FastAPI service (Flutter → FastAPI → Piper). Swaps in place
/// of the mock; tests may override this provider with a fake/mock.
final ttsRepositoryProvider = Provider<TtsRepository>((ref) {
  return HttpTtsRepository(baseUri: Uri.parse(AppConfig.apiBaseUrl));
});

final suggestionRepositoryProvider = Provider<SuggestionRepository>((ref) {
  return MockSuggestionRepository();
});

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  return MockExportRepository();
});
