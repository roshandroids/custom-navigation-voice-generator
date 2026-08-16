import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/state/instruction_editor_state.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';
import 'package:navigation_voice_generator/features/tts/domain/repositories/tts_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/domain/repositories/suggestion_repository.dart';

class FakeInstructionRepository implements InstructionRepository {
  final List<Instruction> instructions = [];

  @override
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId) async =>
      Ok(instructions.where((i) => i.packId == packId).toList());

  @override
  Future<Result<Instruction>> getById(VoicePackId packId, InstructionId id) async {
    for (final instruction in instructions) {
      if (instruction.packId == packId && instruction.id == id) return Ok(instruction);
    }
    return const Err(NotFoundFailure('Instruction not found.'));
  }

  @override
  Future<Result<Instruction>> updateCustomText({
    required VoicePackId packId,
    required InstructionId id,
    required String text,
  }) async {
    final index = instructions.indexWhere((i) => i.packId == packId && i.id == id);
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = instructions[index].withCustomText(text);
    instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> attachAudio({
    required VoicePackId packId,
    required InstructionId id,
    required AudioAsset audio,
  }) async {
    final index = instructions.indexWhere((i) => i.packId == packId && i.id == id);
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = instructions[index].withAudio(audio);
    instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> markRecorded({
    required VoicePackId packId,
    required InstructionId id,
  }) async {
    final index = instructions.indexWhere((i) => i.packId == packId && i.id == id);
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = instructions[index].asRecorded();
    instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<int>> countForPack(VoicePackId packId) async =>
      Ok(instructions.where((i) => i.packId == packId).length);

  @override
  Future<Result<int>> countRecordedForPack(VoicePackId packId) async =>
      Ok(instructions.where((i) => i.packId == packId && i.isRecorded).length);
}

class FakeTtsRepository implements TtsRepository {
  @override
  Future<Result<AudioAsset>> generateAudio(TtsRequest request) async =>
      Ok(
        AudioAsset(
          id: AudioAssetId('audio-1'),
          duration: const Duration(seconds: 4),
          format: AudioFormat.wav,
          kind: AudioKind.clean,
        ),
      );
}

class FakeSuggestionRepository implements SuggestionRepository {
  @override
  Future<Result<List<Suggestion>>> generate(SuggestionRequest request) async =>
      Ok(
        [
          Suggestion(
            text: 'Suggestion ${request.situation}',
            personality: request.personality,
            language: request.language,
          ),
        ],
      );
}

Instruction makeInstruction(VoicePackId packId, String id) => Instruction(
      id: InstructionId(id),
      packId: packId,
      category: InstructionCategory.directions,
      situation: 'बायाँ मोड',
      standardText: 'देब्रे मोड्नुहोस्।',
      customText: 'देब्रे मोड्नुहोस्।',
    );

void main() {
  const packId = VoicePackId('pack-1');
  const voice = VoiceProfile(
    id: 'chitwan',
    language: VoiceLanguage.nepali,
    label: 'Chitwan',
  );

  ProviderContainer makeContainer() {
    final instructionRepo = FakeInstructionRepository()
      ..instructions.add(makeInstruction(packId, 'instr-1'));
    return ProviderContainer(
      overrides: [
        instructionRepositoryProvider.overrideWithValue(instructionRepo),
        ttsRepositoryProvider.overrideWithValue(FakeTtsRepository()),
        suggestionRepositoryProvider.overrideWithValue(FakeSuggestionRepository()),
      ],
    );
  }

  InstructionEditorArgs args() => InstructionEditorArgs(
        packId: 'pack-1',
        instructionId: 'instr-1',
        voice: voice,
        language: VoiceLanguage.nepali,
        personality: Personality.savage,
      );

  group('InstructionEditorNotifier', () {
    Future<void> waitForLoad(ProviderContainer container, InstructionEditorArgs a) async {
      for (var i = 0; i < 100; i++) {
        if (!container.read(instructionEditorProvider(a)).isLoading) return;
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      fail('Editor did not finish loading.');
    }

    test('loads the instruction and initializes the draft', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      final state = container.read(provider);
      expect(state.isLoading, isTrue);

      await waitForLoad(container, args());

      final loaded = container.read(provider);
      expect(loaded.instruction, isNotNull);
      expect(loaded.draftText, 'देब्रे मोड्नुहोस्।');
    });

    test('updateDraft only changes the local draft, not the repository', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      await waitForLoad(container, args());

      container.read(provider.notifier).updateDraft('मेरो आफ्नै निर्देशन');

      final state = container.read(provider);
      expect(state.draftText, 'मेरो आफ्नै निर्देशन');
      final repo = container.read(instructionRepositoryProvider) as FakeInstructionRepository;
      expect(repo.instructions.first.customText, 'देब्रे मोड्नुहोस्।');
    });

    test('saveDraft persists the draft through the use case', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      await waitForLoad(container, args());

      container.read(provider.notifier).updateDraft('मेरो आफ्नै निर्देशन');
      await container.read(provider.notifier).saveDraft();

      final repo = container.read(instructionRepositoryProvider) as FakeInstructionRepository;
      expect(repo.instructions.first.customText, 'मेरो आफ्नै निर्देशन');
    });

    test('applySuggestion updates the draft', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      await waitForLoad(container, args());

      container.read(provider.notifier).applySuggestion('सुझाव निर्देशन');

      expect(container.read(provider).draftText, 'सुझाव निर्देशन');
    });

    test('generateSuggestions loads suggestions', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      await waitForLoad(container, args());

      await container.read(provider.notifier).generateSuggestions();

      final state = container.read(provider);
      expect(state.suggestionStatus, GenerationStatus.success);
      expect(state.suggestions, isNotEmpty);
    });

    test('generateAudio saves text then generates a clean asset', () async {
      final container = makeContainer();
      final provider = instructionEditorProvider(args());
      await waitForLoad(container, args());

      container.read(provider.notifier).updateDraft('मेरो आफ्नै निर्देशन');
      await container.read(provider.notifier).generateAudio();

      final state = container.read(provider);
      expect(state.generationStatus, GenerationStatus.success);
      expect(state.audio, isNotNull);
      expect(state.audio!.kind, AudioKind.clean);
      final repo = container.read(instructionRepositoryProvider) as FakeInstructionRepository;
      expect(repo.instructions.first.customText, 'मेरो आफ्नै निर्देशन');
    });
  });
}
