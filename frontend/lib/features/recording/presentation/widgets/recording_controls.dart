import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';

/// Large recording controls driven by the [RecordingState] machine.
///
/// Buttons are enabled/disabled according to valid transitions; the labels
/// change with the phase. No business logic here — the widget just renders
/// state and dispatches callbacks.
class RecordingControls extends StatelessWidget {
  const RecordingControls({
    super.key,
    required this.phase,
    required this.onPrepare,
    required this.onMarkRecorded,
    required this.onReplay,
    required this.onNext,
    required this.onPrevious,
    this.hasNext = true,
    this.hasPrevious = false,
  });

  final RecordingPhase phase;
  final VoidCallback onPrepare;
  final VoidCallback onMarkRecorded;
  final VoidCallback onReplay;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool hasNext;
  final bool hasPrevious;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPrepare = phase == RecordingPhase.idle;
    final canMarkRecorded = phase == RecordingPhase.completed;
    final canReplay =
        phase == RecordingPhase.completed || phase == RecordingPhase.recorded;
    final showNext = phase == RecordingPhase.recorded;
    final primaryStyle = FilledButton.styleFrom(
      minimumSize: const Size(0, 56),
      textStyle: theme.textTheme.titleMedium,
    );

    return Column(
      children: [
        if (canPrepare)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPrepare,
              style: primaryStyle,
              icon: const Icon(Icons.mic, size: 22),
              label: const Text('Enter Recording Mode'),
            ),
          ),
        if (canMarkRecorded)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onMarkRecorded,
              style: primaryStyle.copyWith(
                backgroundColor: WidgetStatePropertyAll(
                  theme.colorScheme.tertiary,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  theme.colorScheme.onTertiary,
                ),
              ),
              icon: const Icon(Icons.check_circle, size: 22),
              label: const Text('Mark Recorded'),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: hasPrevious ? onPrevious : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
            OutlinedButton.icon(
              onPressed: canReplay ? onReplay : null,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
            ),
            if (showNext && hasNext)
              FilledButton.icon(
                onPressed: onNext,
                style: primaryStyle,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
          ],
        ),
      ],
    );
  }
}
