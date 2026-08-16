import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/generation_button.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/progress_header.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/domain/repositories/export_repository.dart';
import 'package:navigation_voice_generator/features/export/domain/use_cases/export_voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/widgets/category_progress.dart';

/// Export screen: pack summary, completion, category summary, and the export
/// actions.
class ExportPage extends ConsumerStatefulWidget {
  const ExportPage({super.key, required this.packId});

  final String packId;

  @override
  ConsumerState<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends ConsumerState<ExportPage> {
  bool _includeClean = true;
  bool _includeRecording = true;
  bool _exporting = false;
  String? _exportResult;
  String? _exportError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packAsync = ref.watch(packByIdProvider(VoicePackId(widget.packId)));
    final progressAsync = ref.watch(packProgressProvider(VoicePackId(widget.packId)));
    final instructionsAsync = ref.watch(
      packInstructionsProvider(VoicePackId(widget.packId)),
    );

    return AppShell(
      title: 'Export',
      subtitle: 'Review and export your voice pack.',
      child: packAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Message('Voice pack not found.'),
        data: (pack) => ListView(
          children: [
            Text(pack.name.value, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${pack.language.label} • ${pack.voice.label} • ${pack.personality.label}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            progressAsync.when(
              data: (progress) => ProgressHeader(progress: progress),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),

            instructionsAsync.when(
              data: (instructions) => CategoryProgress(instructions: instructions),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Include', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    CheckboxListTile(
                      value: _includeClean,
                      onChanged: (value) =>
                          setState(() => _includeClean = value ?? true),
                      title: const Text('Clean audio (voice only)'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      value: _includeRecording,
                      onChanged: (value) =>
                          setState(() => _includeRecording = value ?? true),
                      title: const Text('Recording audio (with preparation silence)'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_exportError != null) ...[
              Text(
                _exportError!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (_exportResult != null) ...[
              Text(
                _exportResult!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(AppRoutes.packPath(widget.packId)),
                    icon: const Icon(Icons.reviews),
                    label: const Text('Review All'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GenerationButton(
                    label: 'Export Voice Pack',
                    icon: Icons.archive,
                    isLoading: _exporting,
                    onPressed: _export,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'ZIP creation is simulated in this MVP — no files are written.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final packAsync = ref.read(packByIdProvider(VoicePackId(widget.packId)));
    final pack = packAsync.value;
    if (pack == null) {
      setState(() => _exportError = 'Voice pack not found.');
      return;
    }

    setState(() {
      _exporting = true;
      _exportError = null;
      _exportResult = null;
    });

    final result = await ExportVoicePack(
      ref.read(exportRepositoryProvider),
    ).execute(
      packName: pack.name.value,
      includeCleanAudio: _includeClean,
      includeRecordingAudio: _includeRecording,
    );

    if (!mounted) return;
    setState(() {
      _exporting = false;
      if (result.isOk) {
        final bundle = (result as Ok<ExportBundle>).value;
        _exportResult =
            'Export ready: ${bundle.fileCount} files, ${bundle.totalBytes} bytes (simulated).';
      } else {
        _exportError = (result as Err<ExportBundle>).failure.message;
      }
    });
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
