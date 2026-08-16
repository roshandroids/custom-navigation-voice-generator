import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// Segmented personality selector with an example preview per selection.
class PersonalitySelector extends StatelessWidget {
  const PersonalitySelector({
    super.key,
    required this.selected,
    required this.language,
    required this.onSelected,
  });

  final Personality selected;
  final VoiceLanguage language;
  final ValueChanged<Personality> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<Personality>(
          segments: [
            for (final personality in Personality.values)
              ButtonSegment(
                value: personality,
                label: Text(personality.label),
              ),
          ],
          selected: {selected},
          onSelectionChanged: (selection) => onSelected(selection.first),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          selected.exampleFor(language),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
