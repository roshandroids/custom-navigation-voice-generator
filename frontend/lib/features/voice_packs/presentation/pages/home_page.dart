import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/generation_button.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/progress_header.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/state/voice_pack_states.dart';

/// Home screen: brand header, primary CTA, and existing voice packs.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    return AppShell(
      title: 'CustomNav',
      subtitle: 'Create your own navigation voice.',
      child: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HomeState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _MessageState(
        icon: Icons.error_outline,
        message: state.error!,
      );
    }
    if (state.packs.isEmpty) {
      return _MessageState(
        icon: Icons.record_voice_over,
        message: 'Create your first custom navigation voice.',
        ctaLabel: 'Create Voice Pack',
        onCta: () => context.push(AppRoutes.create),
      );
    }
    return ListView(
      children: [
        GenerationButton(
          label: 'Create Voice Pack',
          icon: Icons.add,
          onPressed: () => context.push(AppRoutes.create),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final pack in state.packs) ...[
          _PackCard(pack: pack),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 260,
                child: GenerationButton(
                  label: ctaLabel!,
                  icon: Icons.add,
                  onPressed: onCta!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One voice pack row: name, language · voice · personality, progress, and a
/// continue action.
class _PackCard extends ConsumerWidget {
  const _PackCard({required this.pack});

  final VoicePack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progress = ref.watch(packProgressProvider(pack.id));

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.packPath(pack.id.value)),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pack.name.value, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${pack.language.label} • ${pack.voice.label} • ${pack.personality.label}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              progress.when(
                data: (value) => ProgressHeader(progress: value),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.packPath(pack.id.value)),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
