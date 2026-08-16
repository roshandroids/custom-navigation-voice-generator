import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_instructions.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_next_instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_previous_instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/get_voice_pack_progress.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/mark_instruction_recorded.dart';
import 'package:navigation_voice_generator/features/instructions/domain/use_cases/update_instruction_text.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

class FakeInstructionRepository implements InstructionRepository {
  final List<Instruction> _instructions = [];
  Failure? failure;

  void seed(List<Instruction> instructions) => _instructions.addAll(instructions);

  @override
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    final result = _instructions.where((i) => i.packId == packId).toList();
    return result.isEmpty
        ? const Err(NotFoundFailure('No instructions for pack.'))
        : Ok(result);
  }

  @override
  Future<Result<Instruction>> getById(VoicePackId packId, InstructionId id) async {
    if (failure != null) return Err(failure!);
    for (final instruction in _instructions) {
      if (instruction.packId == packId && instruction.id == id) {
        return Ok(instruction);
      }
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
    final index = _instructions.indexWhere(
      (i) => i.packId == packId && i.id == id,
    );
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _instructions[index].withCustomText(text);
    _instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> attachAudio({
    required VoicePackId packId,
    required InstructionId id,
    required AudioAsset audio,
  }) async {
    if (failure != null) return Err(failure!);
    final index = _instructions.indexWhere(
      (i) => i.packId == packId && i.id == id,
    );
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _instructions[index].withAudio(audio);
    _instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> markRecorded({
    required VoicePackId packId,
    required InstructionId id,
  }) async {
    if (failure != null) return Err(failure!);
    final index = _instructions.indexWhere(
      (i) => i.packId == packId && i.id == id,
    );
    if (index == -1) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _instructions[index].asRecorded();
    _instructions[index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<int>> countForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    return Ok(_instructions.where((i) => i.packId == packId).length);
  }

  @override
  Future<Result<int>> countRecordedForPack(VoicePackId packId) async {
    if (failure != null) return Err(failure!);
    return Ok(
      _instructions.where((i) => i.packId == packId && i.isRecorded).length,
    );
  }
}

Instruction instruction(VoicePackId packId, String id, {bool recorded = false}) =>
    Instruction(
      id: InstructionId(id),
      packId: packId,
      category: InstructionCategory.directions,
      situation: 'Turn $id',
      standardText: 'Turn left.',
      customText: 'Turn left.',
      isRecorded: recorded,
    );

void main() {
  const packId = VoicePackId('pack-1');

  group('GetInstructions', () {
    test('returns instructions for the pack', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a'), instruction(packId, 'b')]);

      final result = await GetInstructions(repository).execute(packId);

      expect(result.isOk, isTrue);
      expect((result as Ok<List<Instruction>>).value, hasLength(2));
    });

    test('propagates failure', () async {
      final repository = FakeInstructionRepository()
        ..failure = const RepositoryFailure('storage down');
      final result = await GetInstructions(repository).execute(packId);

      expect(result.isErr, isTrue);
    });
  });

  group('UpdateInstructionText', () {
    test('updates custom text', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')]);

      final result = await UpdateInstructionText(repository).execute(
        packId: packId,
        instructionId: const InstructionId('a'),
        text: 'My custom instruction',
      );

      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.customText, 'My custom instruction');
      expect(result.value.isCustomized, isTrue);
    });

    test('returns failure when the instruction is missing', () async {
      final result = await UpdateInstructionText(FakeInstructionRepository()).execute(
        packId: packId,
        instructionId: const InstructionId('missing'),
        text: 'x',
      );

      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });

    test('propagates repository failure', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')])
        ..failure = const RepositoryFailure('storage down');
      final result = await UpdateInstructionText(repository).execute(
        packId: packId,
        instructionId: const InstructionId('a'),
        text: 'x',
      );

      expect(result.isErr, isTrue);
    });
  });

  group('MarkInstructionRecorded', () {
    test('marks an instruction recorded', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')]);

      final result = await MarkInstructionRecorded(repository).execute(
        packId: packId,
        instructionId: const InstructionId('a'),
      );

      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.isRecorded, isTrue);
    });

    test('propagates failure', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')])
        ..failure = const RepositoryFailure('storage down');
      final result = await MarkInstructionRecorded(repository).execute(
        packId: packId,
        instructionId: const InstructionId('a'),
      );

      expect(result.isErr, isTrue);
    });
  });

  group('GetVoicePackProgress', () {
    test('zero completed', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a'), instruction(packId, 'b')]);

      final result = await GetVoicePackProgress(repository).execute(packId);

      expect(result.isOk, isTrue);
      final progress = (result as Ok).value;
      expect(progress.recorded, 0);
      expect(progress.total, 2);
    });

    test('partially completed', () async {
      final repository = FakeInstructionRepository()
        ..seed([
          instruction(packId, 'a', recorded: true),
          instruction(packId, 'b'),
        ]);

      final result = await GetVoicePackProgress(repository).execute(packId);

      expect(result.isOk, isTrue);
      final progress = (result as Ok).value;
      expect(progress.recorded, 1);
      expect(progress.total, 2);
      expect(progress.fraction, 0.5);
    });

    test('fully completed', () async {
      final repository = FakeInstructionRepository()
        ..seed([
          instruction(packId, 'a', recorded: true),
          instruction(packId, 'b', recorded: true),
        ]);

      final result = await GetVoicePackProgress(repository).execute(packId);

      expect(result.isOk, isTrue);
      expect((result as Ok).value.isComplete, isTrue);
    });

    test('propagates failure', () async {
      final repository = FakeInstructionRepository()
        ..failure = const RepositoryFailure('storage down');
      final result = await GetVoicePackProgress(repository).execute(packId);

      expect(result.isErr, isTrue);
    });
  });

  group('GetNextInstruction / GetPreviousInstruction', () {
    test('next returns the following instruction in order', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a'), instruction(packId, 'b'), instruction(packId, 'c')]);

      final result = await GetNextInstruction(repository).execute(
        packId: packId,
        currentId: const InstructionId('a'),
      );

      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.id.value, 'b');
    });

    test('next on the final instruction returns NotFoundFailure', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a'), instruction(packId, 'b')]);

      final result = await GetNextInstruction(repository).execute(
        packId: packId,
        currentId: const InstructionId('b'),
      );

      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });

    test('previous returns the preceding instruction in order', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a'), instruction(packId, 'b'), instruction(packId, 'c')]);

      final result = await GetPreviousInstruction(repository).execute(
        packId: packId,
        currentId: const InstructionId('b'),
      );

      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.id.value, 'a');
    });

    test('previous on the first instruction returns NotFoundFailure', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')]);

      final result = await GetPreviousInstruction(repository).execute(
        packId: packId,
        currentId: const InstructionId('a'),
      );

      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });

    test('next on a missing instruction returns NotFoundFailure', () async {
      final repository = FakeInstructionRepository()
        ..seed([instruction(packId, 'a')]);

      final result = await GetNextInstruction(repository).execute(
        packId: packId,
        currentId: const InstructionId('ghost'),
      );

      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });
  });
}
