import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';

/// A linear progress header: "12 / 25 recorded" with a progress bar.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.progress,
    this.compact = false,
  });

  final VoicePackProgress progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (progress.fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.recorded} / ${progress.total} recorded',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '$percent%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: LinearProgressIndicator(
            value: progress.fraction,
            minHeight: compact ? 6 : 10,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
