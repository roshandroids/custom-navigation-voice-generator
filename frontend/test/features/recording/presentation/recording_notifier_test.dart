import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/core/timing/countdown_ticker.dart';
import 'package:navigation_voice_generator/core/timing/playback_scheduler.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// A fake ticker that records the callback so tests can fire ticks manually.
class FakeCountdownTicker implements CountdownTicker {
  void Function()? onTick;
  bool started = false;
  bool stopped = false;

  @override
  void start(Duration interval, void Function() onTick) {
    this.onTick = onTick;
    started = true;
    stopped = false;
  }

  @override
  void stop() {
    stopped = true;
  }

  void fireTick() => onTick?.call();
}

/// A fake playback scheduler that records the completion callback so tests
/// can fire it deterministically.
class FakePlaybackScheduler implements PlaybackScheduler {
  void Function()? onComplete;
  bool cancelled = false;

  @override
  void schedule(Duration delay, void Function() onComplete) {
    this.onComplete = onComplete;
  }

  @override
  void cancel() {
    cancelled = true;
  }

  void fireCompletion() => onComplete?.call();
}

class FakeInstructionRepository implements InstructionRepository {
  final List<Instruction> instructions = [];

  void seed(List<Instruction> list) => instructions.addAll(list);

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

  (
    ProviderContainer,
    FakeCountdownTicker,
    FakePlaybackScheduler,
  ) makeContainer() {
    final repo = FakeInstructionRepository()
      ..seed([
        makeInstruction(packId, 'a'),
        makeInstruction(packId, 'b'),
        makeInstruction(packId, 'c'),
      ]);
    final ticker = FakeCountdownTicker();
    final scheduler = FakePlaybackScheduler();
    final container = ProviderContainer(
      overrides: [
        instructionRepositoryProvider.overrideWithValue(repo),
        countdownTickerProvider.overrideWithValue(ticker),
        playbackSchedulerProvider.overrideWithValue(scheduler),
        countdownSecondsProvider.overrideWithValue(3),
      ],
    );
    return (container, ticker, scheduler);
  }

  RecordingArgs args(String instructionId) =>
      RecordingArgs(packId: 'pack-1', instructionId: instructionId);

  Future<void> load(ProviderContainer container, RecordingArgs args) async {
    container.read(recordingProvider(args));
    await Future<void>.delayed(Duration.zero);
  }

  group('RecordingNotifier', () {
    test('loads the instruction in idle phase', () async {
      final (container, _, _) = makeContainer();
      await load(container, args('a'));

      final state = container.read(recordingProvider(args('a')));
      expect(state.instruction, isNotNull);
      expect(state.recording.phase, RecordingPhase.idle);
    });

    test('beginPreparation moves to preparing and starts the countdown', () async {
      final (container, ticker, _) = makeContainer();
      await load(container, args('a'));

      container.read(recordingProvider(args('a')).notifier).beginPreparation();

      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.preparing);
      expect(container.read(recordingProvider(args('a'))).recording.countdownRemaining, 3);
      expect(ticker.started, isTrue);
    });

    test('three ticks move through the countdown to playing', () async {
      final (container, ticker, _) = makeContainer();
      await load(container, args('a'));

      final notifier = container.read(recordingProvider(args('a')).notifier);
      notifier.beginPreparation();

      ticker.fireTick();
      expect(container.read(recordingProvider(args('a'))).recording.countdownRemaining, 2);
      ticker.fireTick();
      expect(container.read(recordingProvider(args('a'))).recording.countdownRemaining, 1);
      ticker.fireTick();
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.playing);
    });

    test('countdown completion schedules playback completion', () async {
      final (container, ticker, scheduler) = makeContainer();
      await load(container, args('a'));

      final notifier = container.read(recordingProvider(args('a')).notifier);
      notifier.beginPreparation();
      ticker.fireTick();
      ticker.fireTick();
      ticker.fireTick();

      // Playing phase: the fake scheduler captured the completion callback.
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.playing);
      scheduler.fireCompletion();
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.completed);
    });

    test('startPlayback requires the preparation phase (state machine rule)', () async {
      final (container, _, _) = makeContainer();
      await load(container, args('a'));

      // From idle, startPlayback is an invalid transition.
      container.read(recordingProvider(args('a')).notifier).startPlayback();

      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.idle);
      expect(container.read(recordingProvider(args('a'))).error, isNotNull);
    });

    test('full workflow: prepare -> play -> complete -> record', () async {
      final (container, ticker, scheduler) = makeContainer();
      await load(container, args('a'));

      final notifier = container.read(recordingProvider(args('a')).notifier);
      notifier.beginPreparation();
      ticker.fireTick();
      ticker.fireTick();
      ticker.fireTick();
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.playing);

      scheduler.fireCompletion();
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.completed);

      await notifier.markRecorded();
      expect(container.read(recordingProvider(args('a'))).recording.phase, RecordingPhase.recorded);
      final repo = container.read(instructionRepositoryProvider) as FakeInstructionRepository;
      expect(repo.instructions.first.isRecorded, isTrue);
    });

    test('goNext loads the following instruction in idle', () async {
      final (container, _, _) = makeContainer();
      await load(container, args('a'));

      await container.read(recordingProvider(args('a')).notifier).goNext();

      final state = container.read(recordingProvider(args('a')));
      expect(state.instruction?.id.value, 'b');
      expect(state.recording.phase, RecordingPhase.idle);
    });

    test('goPrevious loads the preceding instruction', () async {
      final (container, _, _) = makeContainer();
      await load(container, args('b'));

      await container.read(recordingProvider(args('b')).notifier).goPrevious();

      expect(container.read(recordingProvider(args('b'))).instruction?.id.value, 'a');
    });

    test('goNext on the final instruction surfaces an error', () async {
      final (container, _, _) = makeContainer();
      await load(container, args('c'));

      await container.read(recordingProvider(args('c')).notifier).goNext();

      expect(container.read(recordingProvider(args('c'))).error, isNotNull);
    });
  });
}
