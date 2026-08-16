import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';

/// Per-category progress chips for the workspace screen.
class CategoryProgress extends StatelessWidget {
  const CategoryProgress({
    super.key,
    required this.instructions,
    this.selectedCategory,
    this.onSelected,
  });

  final List<Instruction> instructions;
  final InstructionCategory? selectedCategory;
  final ValueChanged<InstructionCategory>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = InstructionCategory.values
        .map((category) {
          final items = instructions.where((i) => i.category == category).toList();
          return (
            category: category,
            recorded: items.where((i) => i.isRecorded).length,
            total: items.length,
          );
        })
        .where((entry) => entry.total > 0)
        .toList();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in categories)
          _CategoryChip(
            category: entry.category,
            recorded: entry.recorded,
            total: entry.total,
            selected: entry.category == selectedCategory,
            onTap: onSelected == null ? null : () => onSelected!(entry.category),
            theme: theme,
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.recorded,
    required this.total,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final InstructionCategory category;
  final int recorded;
  final int total;
  final bool selected;
  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final complete = recorded == total && total > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.6 : 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (complete) ...[
              Icon(Icons.check_circle, size: 16, color: theme.colorScheme.tertiary),
              const SizedBox(width: 6),
            ],
            Text(
              '${category.label} · $recorded/$total',
              style: theme.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
