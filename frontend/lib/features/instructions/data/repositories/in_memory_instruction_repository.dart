import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/data/corpus/corpus_entry.dart';
import 'package:navigation_voice_generator/features/instructions/data/corpus/sample_corpus.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Maps a [CorpusEntry] to an [Instruction].
///
/// A new instruction starts with the standard text as its custom text (the
/// "initial state" of the instruction lifecycle).
Instruction instructionFromCorpus(VoicePackId packId, CorpusEntry entry) =>
    Instruction(
      id: InstructionId(entry.id),
      packId: packId,
      category: entry.category,
      situation: entry.situation,
      standardText: entry.text,
      customText: entry.text,
    );

/// In-memory instruction storage for the MVP.
///
/// [seeded] pre-populates a Nepali pack (`seed-ne`) and an English pack
/// (`seed-en`) with the finalized sample corpus content so the app runs
/// without Python. The repository is replaceable by a persistence-backed
/// implementation without touching domain or presentation.
class InMemoryInstructionRepository implements InstructionRepository {
  InMemoryInstructionRepository() : _packs = <VoicePackId, List<Instruction>>{};

  InMemoryInstructionRepository.seeded()
      : _packs = <VoicePackId, List<Instruction>>{} {
    seedPack(
      const VoicePackId('seed-ne'),
      SampleCorpus.nepali
          .map((entry) => instructionFromCorpus(const VoicePackId('seed-ne'), entry))
          .toList(),
    );
    seedPack(
      const VoicePackId('seed-en'),
      SampleCorpus.english
          .map((entry) => instructionFromCorpus(const VoicePackId('seed-en'), entry))
          .toList(),
    );
  }

  final Map<VoicePackId, List<Instruction>> _packs;

  /// Seeds a pack from ready-made [Instruction]s. Test hook.
  void seedPack(VoicePackId packId, List<Instruction> instructions) {
    _packs[packId] = List.of(instructions);
  }

  @override
  Future<Result<List<Instruction>>> getForPack(VoicePackId packId) async {
    final instructions = _packs[packId];
    if (instructions == null) {
      return const Err(NotFoundFailure('No instructions for this pack.'));
    }
    return Ok(List.unmodifiable(instructions));
  }

  @override
  Future<Result<Instruction>> getById(
    VoicePackId packId,
    InstructionId id,
  ) async {
    final instructions = _packs[packId];
    if (instructions == null) {
      return const Err(NotFoundFailure('No instructions for this pack.'));
    }
    for (final instruction in instructions) {
      if (instruction.id == id) return Ok(instruction);
    }
    return const Err(NotFoundFailure('Instruction not found.'));
  }

  @override
  Future<Result<Instruction>> updateCustomText({
    required VoicePackId packId,
    required InstructionId id,
    required String text,
  }) async {
    final index = _indexOf(packId, id);
    if (index == null) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _packs[packId]![index].withCustomText(text);
    _packs[packId]![index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> attachAudio({
    required VoicePackId packId,
    required InstructionId id,
    required AudioAsset audio,
  }) async {
    final index = _indexOf(packId, id);
    if (index == null) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _packs[packId]![index].withAudio(audio);
    _packs[packId]![index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<Instruction>> markRecorded({
    required VoicePackId packId,
    required InstructionId id,
  }) async {
    final index = _indexOf(packId, id);
    if (index == null) return const Err(NotFoundFailure('Instruction not found.'));
    final updated = _packs[packId]![index].asRecorded();
    _packs[packId]![index] = updated;
    return Ok(updated);
  }

  @override
  Future<Result<int>> countForPack(VoicePackId packId) async {
    final instructions = _packs[packId];
    if (instructions == null) {
      return const Err(NotFoundFailure('No instructions for this pack.'));
    }
    return Ok(instructions.length);
  }

  @override
  Future<Result<int>> countRecordedForPack(VoicePackId packId) async {
    final instructions = _packs[packId];
    if (instructions == null) {
      return const Err(NotFoundFailure('No instructions for this pack.'));
    }
    return Ok(instructions.where((i) => i.isRecorded).length);
  }

  int? _indexOf(VoicePackId packId, InstructionId id) {
    final instructions = _packs[packId];
    if (instructions == null) return null;
    for (var i = 0; i < instructions.length; i++) {
      if (instructions[i].id == id) return i;
    }
    return null;
  }
}
