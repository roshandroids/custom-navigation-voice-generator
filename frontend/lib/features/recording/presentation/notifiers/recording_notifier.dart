import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/core/timing/audio_playback.dart';
import 'package:navigation_voice_generator/core/timing/countdown_ticker.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';
import 'package:navigation_voice_generator/features/recording/presentation/state/recording_screen_state.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Drives the recording workflow screen.
///
/// The recording phase machine lives in the domain ([RecordingState]); this
/// notifier coordinates it with playback (playing the instruction's real
/// generated audio and auto-advancing to `completed` when playback ends) and
/// instruction navigation.
class RecordingNotifier extends Notifier<RecordingScreenState> {
  RecordingNotifier(this.args);

  final RecordingArgs args;

  String get packId => args.packId;
  String get instructionId => args.instructionId;

  late final int countdownSeconds = ref.read(countdownSecondsProvider);
  late final CountdownTicker _ticker = ref.read(countdownTickerProvider);
  late final AudioPlayback _audioPlayback = ref.read(audioPlaybackProvider);

  /// How long playback is simulated when the asset carries no real audio
  /// (mock / metadata-only assets).
  static const simulatedPlaybackDuration = Duration(seconds: 3);

  @override
  RecordingScreenState build() {
    ref.onDispose(_ticker.stop);
    ref.onDispose(_audioPlayback.cancel);
    _load();
    return const RecordingScreenState.loading();
  }

  Future<void> _load() async {
    final result = await ref
        .read(getInstructionProvider)
        .execute(VoicePackId(packId), InstructionId(instructionId));
    if (result.isErr) {
      state = RecordingScreenState.failure(_messageFor(result));
      return;
    }
    final instruction = (result as Ok<Instruction>).value;
    state = RecordingScreenState.data(instruction, const RecordingIdle());
  }

  /// Enters the preparation phase and starts the visual countdown.
  void beginPreparation() {
    final current = state.instruction;
    if (current == null) return;
    final transition = state.recording.beginPreparation();
    if (transition.isErr) {
      _invalidTransition(transition);
      return;
    }
    state = RecordingScreenState.data(
      current,
      (transition as Ok<RecordingState>).value,
    );
    _startCountdown();
  }

  /// Advances the countdown by one tick; when it reaches zero, playback
  /// starts automatically.
  void tick() {
    final current = state.instruction;
    if (current == null) return;
    final transition = state.recording.tick();
    if (transition.isErr) {
      _invalidTransition(transition);
      return;
    }
    final next = (transition as Ok<RecordingState>).value;
    state = RecordingScreenState.data(current, next);
    if (next.phase == RecordingPhase.playing) {
      _schedulePlaybackComplete();
    }
  }

  /// Starts playback immediately, skipping the countdown.
  void startPlayback() {
    final current = state.instruction;
    if (current == null) return;
    final transition = state.recording.startPlayback();
    if (transition.isErr) {
      _invalidTransition(transition);
      return;
    }
    _ticker.stop();
    state = RecordingScreenState.data(
      current,
      (transition as Ok<RecordingState>).value,
    );
    _schedulePlaybackComplete();
  }

  /// Marks the instruction as recorded in the workflow.
  Future<void> markRecorded() async {
    final current = state.instruction;
    if (current == null) return;
    final transition = state.recording.markRecorded();
    if (transition.isErr) {
      _invalidTransition(transition);
      return;
    }
    _ticker.stop();
    state = RecordingScreenState.data(
      current,
      (transition as Ok<RecordingState>).value,
    );

    final result = await ref.read(markInstructionRecordedProvider).execute(
          packId: VoicePackId(packId),
          instructionId: InstructionId(instructionId),
        );
    if (result.isErr) {
      state = RecordingScreenState.failure(_messageFor(result));
      return;
    }
    final updated = (result as Ok<Instruction>).value;
    state = RecordingScreenState.data(updated, state.recording);
  }

  /// Moves to the next instruction (or the previous one with [goPrevious]).
  Future<void> goNext() async {
    _ticker.stop();
    final result = await ref.read(getNextInstructionProvider).execute(
          packId: VoicePackId(packId),
          currentId: InstructionId(instructionId),
        );
    if (result.isErr) {
      state = RecordingScreenState.failure(_messageFor(result));
      return;
    }
    final next = (result as Ok<Instruction>).value;
    state = RecordingScreenState.data(next, const RecordingIdle());
  }

  Future<void> goPrevious() async {
    _ticker.stop();
    final result = await ref.read(getPreviousInstructionProvider).execute(
          packId: VoicePackId(packId),
          currentId: InstructionId(instructionId),
        );
    if (result.isErr) {
      state = RecordingScreenState.failure(_messageFor(result));
      return;
    }
    final previous = (result as Ok<Instruction>).value;
    state = RecordingScreenState.data(previous, const RecordingIdle());
  }

  void _startCountdown() {
    _ticker.stop();
    var ticks = 0;
    _ticker.start(const Duration(seconds: 1), () {
      ticks++;
      if (ticks >= countdownSeconds) {
        _ticker.stop();
        tick(); // final tick moves to playing
        return;
      }
      tick();
    });
  }

  void _schedulePlaybackComplete() {
    final current = state.instruction;
    if (current == null) return;
    final asset = current.audio;

    _audioPlayback.start(
      bytes: asset?.bytes,
      uri: asset?.uri,
      // Metadata-only (mock) assets fall back to a fixed simulated duration;
      // real assets complete from the player's onPlayerComplete signal.
      simulatedDuration:
          asset?.duration ?? simulatedPlaybackDuration,
      onComplete: () {
        if (state.recording.phase == RecordingPhase.playing) {
          _completePlayback();
        }
      },
    );
  }

  void _completePlayback() {
    final current = state.instruction;
    if (current == null) return;
    final transition = state.recording.completePlayback();
    if (transition.isErr) {
      _invalidTransition(transition);
      return;
    }
    state = RecordingScreenState.data(
      current,
      (transition as Ok<RecordingState>).value,
    );
  }

  void _invalidTransition(Result<RecordingState> result) {
    state = RecordingScreenState.failure(
      (result as Err<RecordingState>).failure.message,
    );
  }
}

String _messageFor(Result result) {
  final failure = result is Err ? result.failure : const UnexpectedFailure('Unknown error.');
  return _friendlyMessage(failure);
}

String _friendlyMessage(Failure failure) => switch (failure) {
      NotFoundFailure() => 'Not found.',
      _ => 'Something went wrong.',
    };
