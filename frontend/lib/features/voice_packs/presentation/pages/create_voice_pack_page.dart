import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/generation_button.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/widgets/personality_selector.dart';

/// Create Voice Pack form screen.
class CreateVoicePackPage extends ConsumerWidget {
  const CreateVoicePackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createVoicePackFormProvider);
    final notifier = ref.read(createVoicePackFormProvider.notifier);

    return AppShell(
      title: 'Create Voice Pack',
      subtitle: 'Pick a language, voice, and personality.',
      child: ListView(
        children: [
          TextField(
            key: const Key('pack-name-field'),
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'My Nepali Voice',
            ),
            onChanged: notifier.updateName,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<VoiceLanguage>(
            segments: const [
              ButtonSegment(value: VoiceLanguage.nepali, label: Text('Nepali')),
              ButtonSegment(value: VoiceLanguage.english, label: Text('English')),
            ],
            selected: {state.language},
            onSelectionChanged: (selection) => notifier.updateLanguage(selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Voice', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ..._voiceOptions(context, state.language, state.voice, notifier.updateVoice),
          const SizedBox(height: AppSpacing.lg),

          Text('Personality', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          PersonalitySelector(
            selected: state.personality,
            language: state.language,
            onSelected: notifier.updatePersonality,
          ),
          const SizedBox(height: AppSpacing.lg),

          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!),
            const SizedBox(height: AppSpacing.md),
          ],

          GenerationButton(
            label: 'Create Voice Pack',
            icon: Icons.auto_awesome,
            isLoading: state.isSubmitting,
            onPressed: () async {
              final pack = await notifier.create();
              if (pack != null && context.mounted) {
                context.go(AppRoutes.packPath(pack.id.value));
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _voiceOptions(
    BuildContext context,
    VoiceLanguage language,
    VoiceProfile selected,
    ValueChanged<VoiceProfile> onSelected,
  ) {
    return [
      RadioGroup<VoiceProfile>(
        groupValue: selected,
        onChanged: (value) {
          if (value != null) onSelected(value);
        },
        child: Column(
          children: [
            for (final voice in VoiceCatalog.forLanguage(language))
              RadioListTile<VoiceProfile>(
                key: Key('voice-${voice.id}'),
                value: voice,
                title: Text(voice.label),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    ];
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
