import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';

/// The recording screen state, driven by the domain [RecordingState] machine.
final class RecordingScreenState {
  const RecordingScreenState({
    required this.isLoading,
    this.instruction,
    this.recording = const RecordingIdle(),
    this.error,
  });

  const RecordingScreenState.loading() : this(isLoading: true);

  RecordingScreenState.data(Instruction instruction, RecordingState recording)
      : this(isLoading: false, instruction: instruction, recording: recording);

  const RecordingScreenState.failure(String message)
      : this(isLoading: false, error: message);

  final bool isLoading;
  final Instruction? instruction;
  final RecordingState recording;
  final String? error;
}
