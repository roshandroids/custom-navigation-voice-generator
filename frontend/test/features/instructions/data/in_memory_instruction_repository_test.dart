import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/data/repositories/in_memory_instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

void main() {
  const packId = VoicePackId('pack-1');
  const otherPackId = VoicePackId('pack-2');

  InMemoryInstructionRepository buildRepository() {
    final repository = InMemoryInstructionRepository.seeded();
    repository.seedPack(
      packId,
      const [
        Instruction(
          id: InstructionId('a'),
          packId: packId,
          category: InstructionCategory.directions,
          situation: 'बायाँ मोड',
          standardText: 'देब्रे मोड्नुहोस्।',
          customText: 'देब्रे मोड्नुहोस्।',
        ),
        Instruction(
          id: InstructionId('b'),
          packId: packId,
          category: InstructionCategory.directions,
          situation: 'दायाँ मोड',
          standardText: 'दायाँ मोड्नुहोस्।',
          customText: 'दायाँ मोड्नुहोस्।',
        ),
      ],
    );
    return repository;
  }

  group('InMemoryInstructionRepository', () {
    test('seeded() creates instructions for both sample languages', () async {
      final repository = InMemoryInstructionRepository.seeded();
      final nepali = await repository.getForPack(const VoicePackId('seed-ne'));
      final english = await repository.getForPack(const VoicePackId('seed-en'));
      expect(nepali, isA<Result<List<Instruction>>>());
      expect(english, isA<Result<List<Instruction>>>());
    });

    test('getForPack returns the pack instructions', () async {
      final repository = buildRepository();
      final result = await repository.getForPack(packId);
      expect(result.isOk, isTrue);
      expect((result as Ok<List<Instruction>>).value, hasLength(2));
    });

    test('getForPack returns NotFoundFailure for an unknown pack', () async {
      final repository = buildRepository();
      final result = await repository.getForPack(const VoicePackId('ghost'));
      expect(result.isErr, isTrue);
      expect((result as Err<List<Instruction>>).failure, isA<NotFoundFailure>());
    });

    test('getById returns the requested instruction', () async {
      final repository = buildRepository();
      final result = await repository.getById(packId, const InstructionId('b'));
      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.id.value, 'b');
    });

    test('getById returns NotFoundFailure for a missing instruction', () async {
      final repository = buildRepository();
      final result = await repository.getById(packId, const InstructionId('ghost'));
      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });

    test('updateCustomText persists the new text', () async {
      final repository = buildRepository();
      final result = await repository.updateCustomText(
        packId: packId,
        id: const InstructionId('a'),
        text: 'ल, देब्रे मोड्नुहोस् है।',
      );
      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.customText, 'ल, देब्रे मोड्नुहोस् है।');

      final reloaded = await repository.getById(packId, const InstructionId('a'));
      expect((reloaded as Ok<Instruction>).value.customText, 'ल, देब्रे मोड्नुहोस् है।');
    });

    test('attachAudio stores the audio on the instruction', () async {
      final repository = buildRepository();
      const audio = AudioAsset(
        id: AudioAssetId('audio-1'),
        duration: Duration(seconds: 4),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      );
      final result = await repository.attachAudio(
        packId: packId,
        id: const InstructionId('a'),
        audio: audio,
      );
      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.audio, audio);
    });

    test('markRecorded marks the instruction recorded', () async {
      final repository = buildRepository();
      final result = await repository.markRecorded(
        packId: packId,
        id: const InstructionId('a'),
      );
      expect(result.isOk, isTrue);
      expect((result as Ok<Instruction>).value.isRecorded, isTrue);
    });

    test('countForPack counts only that pack', () async {
      final repository = buildRepository();
      repository.seedPack(
        otherPackId,
        const [
          Instruction(
            id: InstructionId('x'),
            packId: otherPackId,
            category: InstructionCategory.arrival,
            situation: 'Arrival',
            standardText: 'You have arrived.',
            customText: 'You have arrived.',
          ),
        ],
      );
      final result = await repository.countForPack(packId);
      expect((result as Ok<int>).value, 2);
    });

    test('countRecordedForPack counts recorded instructions', () async {
      final repository = buildRepository();
      await repository.markRecorded(packId: packId, id: const InstructionId('a'));
      final result = await repository.countRecordedForPack(packId);
      expect((result as Ok<int>).value, 1);
    });

    test('mutations for an unknown pack return NotFoundFailure', () async {
      final repository = buildRepository();
      final result = await repository.updateCustomText(
        packId: const VoicePackId('ghost'),
        id: const InstructionId('a'),
        text: 'x',
      );
      expect(result.isErr, isTrue);
      expect((result as Err<Instruction>).failure, isA<NotFoundFailure>());
    });
  });
}
