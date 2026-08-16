import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/core/timing/countdown_ticker.dart';
import 'package:navigation_voice_generator/core/timing/playback_scheduler.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/notifiers/instruction_editor_notifier.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/state/instruction_editor_state.dart';
import 'package:navigation_voice_generator/features/recording/presentation/notifiers/recording_notifier.dart';
import 'package:navigation_voice_generator/features/recording/presentation/state/recording_screen_state.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/notifiers/create_voice_pack_notifier.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/notifiers/home_notifier.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/notifiers/workspace_notifier.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/state/voice_pack_states.dart';

/// Presentation providers. The UI watches these; they never touch
/// repositories directly.

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);

final createVoicePackFormProvider =
    NotifierProvider<CreateVoicePackNotifier, CreateVoicePackFormState>(
  CreateVoicePackNotifier.new,
);

final workspaceProvider =
    NotifierProvider<WorkspaceNotifier, WorkspaceState>(WorkspaceNotifier.new);

/// Family of editor notifiers, one per (pack, instruction) pair.
final instructionEditorProvider =
    NotifierProvider.family<InstructionEditorNotifier, InstructionEditorState,
        InstructionEditorArgs>(
  InstructionEditorNotifier.new,
);

/// Family of recording notifiers, one per (pack, instruction) pair.
final recordingProvider = NotifierProvider
    .family<RecordingNotifier, RecordingScreenState, RecordingArgs>(
  RecordingNotifier.new,
);

/// Arguments identifying an instruction editor session.
final class InstructionEditorArgs {
  const InstructionEditorArgs({
    required this.packId,
    required this.instructionId,
    required this.voice,
    required this.language,
    required this.personality,
  });

  final String packId;
  final String instructionId;
  final VoiceProfile voice;
  final VoiceLanguage language;
  final Personality personality;

  @override
  bool operator ==(Object other) =>
      other is InstructionEditorArgs &&
      other.packId == packId &&
      other.instructionId == instructionId;

  @override
  int get hashCode => Object.hash(packId, instructionId);
}

/// Arguments identifying a recording session.
final class RecordingArgs {
  const RecordingArgs({
    required this.packId,
    required this.instructionId,
  });

  final String packId;
  final String instructionId;

  @override
  bool operator ==(Object other) =>
      other is RecordingArgs &&
      other.packId == packId &&
      other.instructionId == instructionId;

  @override
  int get hashCode => Object.hash(packId, instructionId);
}

/// Provider for the countdown ticker — overridable in tests with a fake.
final countdownTickerProvider = Provider<CountdownTicker>((ref) {
  return TimerCountdownTicker();
});

/// Provider for the playback scheduler — overridable in tests with a fake.
final playbackSchedulerProvider = Provider<PlaybackScheduler>((ref) {
  return TimerPlaybackScheduler();
});

/// The default countdown duration in seconds (visual preparation phase).
final countdownSecondsProvider = Provider<int>((ref) => 3);
