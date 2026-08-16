import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/status_badge.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';

/// A tappable card showing an instruction's situation, standard and custom
/// text, and its recording status.
class InstructionCard extends StatelessWidget {
  const InstructionCard({
    super.key,
    required this.instruction,
    required this.onTap,
  });

  final Instruction instruction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            instruction.situation,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        StatusBadge(
                          label: instruction.isRecorded ? 'Recorded' : 'Pending',
                          icon: instruction.isRecorded
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: instruction.isRecorded
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      instruction.standardText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (instruction.isCustomized) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        instruction.customText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
