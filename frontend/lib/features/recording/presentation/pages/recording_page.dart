import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';
import 'package:navigation_voice_generator/features/recording/presentation/notifiers/recording_notifier.dart';
import 'package:navigation_voice_generator/features/recording/presentation/state/recording_screen_state.dart';
import 'package:navigation_voice_generator/features/recording/presentation/widgets/recording_controls.dart';

/// Recording mode: focused screen with a large visual countdown, playback
/// indicator, and large controls driven by the recording state machine.
class RecordingPage extends ConsumerWidget {
  const RecordingPage({
    super.key,
    required this.packId,
    required this.instructionId,
  });

  final String packId;
  final String instructionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = RecordingArgs(packId: packId, instructionId: instructionId);
    final state = ref.watch(recordingProvider(args));
    final notifier = ref.read(recordingProvider(args).notifier);
    // Recording mode: on desktop widen the content area for large controls.
    final wideLayout = MediaQuery.sizeOf(context).width >= 900;

    return AppShell(
      title: 'Recording',
      subtitle: 'Listen, then record into Waze.',
      maxContentWidth: wideLayout ? 720 : 560,
      child: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecordingScreenState state,
    RecordingNotifier notifier,
  ) {
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _CenteredMessage(
        message: state.error!,
        actionLabel: 'Back to editor',
        onAction: () =>
            context.go(AppRoutes.instructionPath(packId, instructionId)),
      );
    }

    final instruction = state.instruction!;
    final recording = state.recording;

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instruction.situation, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  instruction.standardText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  instruction.customText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Large phase indicator + countdown.
        _PhasePanel(recording: recording, countdownSeconds: 3),
        const SizedBox(height: AppSpacing.lg),

        RecordingControls(
          phase: recording.phase,
          onPrepare: notifier.beginPreparation,
          onMarkRecorded: () => notifier.markRecorded(),
          onReplay: notifier.startPlayback,
          onNext: () => notifier.goNext(),
          onPrevious: () => notifier.goPrevious(),
          hasNext: true,
          hasPrevious: true,
        ),
        const SizedBox(height: AppSpacing.lg),

        TextButton.icon(
          onPressed: () =>
              context.go(AppRoutes.instructionPath(packId, instructionId)),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to editor'),
        ),
      ],
    );
  }
}

class _PhasePanel extends StatelessWidget {
  const _PhasePanel({required this.recording, required this.countdownSeconds});

  final RecordingState recording;
  final int countdownSeconds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = recording.phase;

    final (icon, label, hint) = switch (phase) {
      RecordingPhase.idle => (
        Icons.mic_none,
        'Ready',
        'Start the preparation countdown when you are ready.',
      ),
      RecordingPhase.preparing => (
        Icons.timer,
        'Get ready…',
        'Speak the instruction when playback starts.',
      ),
      RecordingPhase.playing => (
        Icons.graphic_eq,
        'Recording…',
        'Playback is running — record it into Waze now.',
      ),
      RecordingPhase.completed => (
        Icons.check,
        'Playback finished',
        'Mark it recorded if it sounded right.',
      ),
      RecordingPhase.recorded => (
        Icons.check_circle,
        'Recorded!',
        'Move to the next instruction.',
      ),
    };

    return Semantics(
      liveRegion: true,
      label: 'Recording phase: $label. $hint',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: Column(
          children: [
            if (phase == RecordingPhase.preparing) ...[
              Text(
                '${recording.countdownRemaining}',
                key: const Key('countdown-value'),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else ...[
              Icon(icon, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(label, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
