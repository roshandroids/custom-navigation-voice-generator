import 'package:flutter/material.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';

/// A primary action button with a loading state.
class GenerationButton extends StatelessWidget {
  const GenerationButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );
    if (isFullWidth) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
