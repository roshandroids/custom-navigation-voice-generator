import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/generation_button.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/status_badge.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/state/instruction_editor_state.dart';
import 'package:navigation_voice_generator/features/tts/presentation/widgets/audio_player.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Instruction editor: standard + custom text, suggestions, audio preview,
/// and the entry into recording mode.
class InstructionEditorPage extends ConsumerWidget {
  const InstructionEditorPage({
    super.key,
    required this.packId,
    required this.instructionId,
  });

  final String packId;
  final String instructionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Resolve the pack for the voice/language/personality settings.
    final packAsync = ref.watch(packByIdProvider(VoicePackId(packId)));
    return AppShell(
      title: 'Instruction',
      subtitle: 'Write your own words.',
      child: packAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Message('Could not load this voice pack.'),
        data: (pack) => _EditorBody(
          packId: packId,
          instructionId: instructionId,
          pack: pack,
        ),
      ),
    );
  }
}

class _EditorBody extends ConsumerWidget {
  const _EditorBody({
    required this.packId,
    required this.instructionId,
    required this.pack,
  });

  final String packId;
  final String instructionId;
  final VoicePack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = InstructionEditorArgs(
      packId: packId,
      instructionId: instructionId,
      voice: pack.voice,
      language: pack.language,
      personality: pack.personality,
    );
    final state = ref.watch(instructionEditorProvider(args));
    final notifier = ref.read(instructionEditorProvider(args).notifier);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.instruction == null) {
      return const _Message('This instruction does not exist.');
    }

    final instruction = state.instruction!;
    final theme = Theme.of(context);

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                instruction.situation,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            StatusBadge(
              label: instruction.isRecorded ? 'Recorded' : 'Pending',
              icon: instruction.isRecorded ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standard instruction',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(instruction.standardText, style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          key: const Key('custom-text-field'),
          controller: TextEditingController(text: state.draftText ?? ''),
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Your instruction',
            hintText: 'Write it the way you would say it.',
          ),
          onChanged: notifier.updateDraft,
        ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          '${pack.personality.label} personality',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        if (state.saveErrorMessage != null) ...[
          _ErrorText(message: state.saveErrorMessage!),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.audioErrorMessage != null) ...[
          _ErrorText(message: state.audioErrorMessage!),
          const SizedBox(height: AppSpacing.sm),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async => notifier.saveDraft(),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: GenerationButton(
                label: 'Generate Suggestions',
                icon: Icons.auto_fix_high,
                isLoading: state.suggestionStatus == GenerationStatus.loading,
                onPressed: () async => notifier.generateSuggestions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (state.suggestionErrorMessage != null) ...[
          _ErrorText(message: state.suggestionErrorMessage!),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (state.suggestionStatus == GenerationStatus.success &&
            state.suggestions.isNotEmpty) ...[
          Text('Suggestions', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final suggestion in state.suggestions) ...[
            _SuggestionTile(
              text: suggestion.text,
              onApply: () => notifier.applySuggestion(suggestion.text),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        const SizedBox(height: AppSpacing.md),

        GenerationButton(
          label: 'Generate Audio',
          icon: Icons.graphic_eq,
          isLoading: state.generationStatus == GenerationStatus.loading,
          onPressed: () async => notifier.generateAudio(),
        ),
        const SizedBox(height: AppSpacing.md),

        if (state.audio != null)
          AudioPlayer(
            audio: state.audio!,
            onPlay: () {},
            onStop: () {},
          ),
        const SizedBox(height: AppSpacing.lg),

        FilledButton.icon(
          key: const Key('enter-recording-button'),
          onPressed: () => context.push(
            AppRoutes.recordPath(packId, instructionId),
          ),
          icon: const Icon(Icons.mic),
          label: const Text('Enter Recording Mode'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text, required this.onApply});

  final String text;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(text),
        trailing: FilledButton.tonal(
          onPressed: onApply,
          child: const Text('Use'),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
