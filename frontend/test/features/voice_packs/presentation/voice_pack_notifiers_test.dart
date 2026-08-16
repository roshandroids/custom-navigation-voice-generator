import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/repositories/voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

class FakeVoicePackRepository implements VoicePackRepository {
  final List<VoicePack> packs = [];
  Failure? failure;

  @override
  Future<Result<VoicePack>> create(VoicePack voice) async {
    if (failure != null) return Err(failure!);
    packs.add(voice);
    return Ok(voice);
  }

  @override
  Future<Result<VoicePack>> getById(VoicePackId id) async {
    if (failure != null) return Err(failure!);
    for (final pack in packs) {
      if (pack.id == id) return Ok(pack);
    }
    return const Err(NotFoundFailure('Voice pack not found.'));
  }

  @override
  Future<Result<List<VoicePack>>> getAll() async {
    if (failure != null) return Err(failure!);
    return Ok(List.of(packs));
  }
}

class FakeInstructionRepository implements InstructionRepository {
  final List<Instruction> instructions = [];
  Failure? failure;

  @override
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    final list = instructions.where((i) => i.packId == packId).toList();
    return list.isEmpty
        ? const Err(NotFoundFailure('No instructions.'))
        : Ok(list);
  }

  @override
  Future<Result<Instruction>> getById(VoicePackId packId, InstructionId id) async {
    if (failure != null) return Err(failure!);
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
    if (failure != null) return Err(failure!);
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
    if (failure != null) return Err(failure!);
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
    if (failure != null) return Err(failure!);
    final index = instructions.indexWhere((i) => i.packId == packId && i.id == id);
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = instructions[index].asRecorded();
    instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<int>> countForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    return Ok(instructions.where((i) => i.packId == packId).length);
  }

  @override
  Future<Result<int>> countRecordedForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    return Ok(instructions.where((i) => i.packId == packId && i.isRecorded).length);
  }
}

VoicePack makePack(String id) => VoicePack(
      id: VoicePackId(id),
      name: (VoicePackName.create('My Voice') as Ok<VoicePackName>).value,
      language: VoiceLanguage.nepali,
      voice: VoiceCatalog.nepali.first,
      personality: Personality.savage,
      createdAt: DateTime(2026, 8, 15),
    );

Instruction makeInstruction(VoicePackId packId, String id) => Instruction(
      id: InstructionId(id),
      packId: packId,
      category: InstructionCategory.directions,
      situation: 'बायाँ मोड',
      standardText: 'देब्रे मोड्नुहोस्।',
      customText: 'देब्रे मोड्नुहोस्।',
    );

ProviderContainer makeContainer({
  FakeVoicePackRepository? voicePacks,
  FakeInstructionRepository? instructions,
}) {
  final voicePackRepo = voicePacks ?? FakeVoicePackRepository();
  final instructionRepo = instructions ?? FakeInstructionRepository();
  return ProviderContainer(
    overrides: [
      voicePackRepositoryProvider.overrideWithValue(voicePackRepo),
      instructionRepositoryProvider.overrideWithValue(instructionRepo),
    ],
  );
}

void main() {
  group('HomeNotifier', () {
    test('loads the voice pack list', () async {
      final repo = FakeVoicePackRepository()
        ..packs.addAll([makePack('pack-1'), makePack('pack-2')]);
      final container = makeContainer(voicePacks: repo);

      // Reading the provider triggers build(), which kicks off the async load.
      final state = container.read(homeProvider);
      expect(state.isLoading, isTrue);

      await Future<void>.delayed(Duration.zero);

      final loaded = container.read(homeProvider);
      expect(loaded.packs, hasLength(2));
      expect(loaded.error, isNull);
    });

    test('failure surfaces an error', () async {
      final repo = FakeVoicePackRepository()..failure = const RepositoryFailure('down');
      final container = makeContainer(voicePacks: repo);

      container.read(homeProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(homeProvider).error, isNotNull);
    });
  });

  group('CreateVoicePackNotifier', () {
    test('initial state has default language and voice', () {
      final container = makeContainer();
      final state = container.read(createVoicePackFormProvider);
      expect(state.language, VoiceLanguage.nepali);
      expect(state.voice.id, 'chitwan');
      expect(state.name, '');
    });

    test('create dispatches the use case and returns the pack', () async {
      final repo = FakeVoicePackRepository();
      final container = makeContainer(voicePacks: repo);

      final notifier = container.read(createVoicePackFormProvider.notifier);
      notifier.updateName('My Nepali Voice');
      notifier.updateLanguage(VoiceLanguage.english);
      notifier.updateVoice(VoiceCatalog.english[1]);
      notifier.updatePersonality(Personality.firm);

      final pack = await notifier.create();

      expect(pack, isNotNull);
      expect(pack!.name.value, 'My Nepali Voice');
      expect(pack.language, VoiceLanguage.english);
      expect(pack.voice.id, 'kristin');
      expect(repo.packs, hasLength(1));
    });

    test('create with an empty name returns null and sets an error', () async {
      final container = makeContainer();
      final notifier = container.read(createVoicePackFormProvider.notifier);

      final pack = await notifier.create();

      expect(pack, isNull);
      expect(container.read(createVoicePackFormProvider).errorMessage, isNotNull);
    });

    test('create propagates repository failure as an error message', () async {
      final repo = FakeVoicePackRepository()..failure = const RepositoryFailure('down');
      final container = makeContainer(voicePacks: repo);
      final notifier = container.read(createVoicePackFormProvider.notifier);
      notifier.updateName('My Voice');

      final pack = await notifier.create();

      expect(pack, isNull);
      expect(container.read(createVoicePackFormProvider).errorMessage, isNotNull);
    });
  });

  group('WorkspaceNotifier', () {
    test('loads pack, instructions and progress', () async {
      final voicePacks = FakeVoicePackRepository()..packs.add(makePack('pack-1'));
      final instructions = FakeInstructionRepository()
        ..instructions.addAll([
          makeInstruction(const VoicePackId('pack-1'), 'a'),
          makeInstruction(const VoicePackId('pack-1'), 'b'),
        ]);
      final container = makeContainer(voicePacks: voicePacks, instructions: instructions);

      await container.read(workspaceProvider.notifier).load('pack-1');

      final state = container.read(workspaceProvider);
      expect(state.isLoading, isFalse);
      expect(state.pack, isNotNull);
      expect(state.instructions, hasLength(2));
      expect(state.progress, isNotNull);
      expect(state.progress!.total, 2);
      expect(state.progress!.recorded, 0);
    });

    test('failure for an unknown pack', () async {
      final container = makeContainer();
      await container.read(workspaceProvider.notifier).load('ghost');
      final state = container.read(workspaceProvider);
      expect(state.error, isNotNull);
    });
  });
}
