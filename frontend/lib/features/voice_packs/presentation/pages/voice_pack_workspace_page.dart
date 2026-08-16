import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/di/presentation_providers.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/progress_header.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/state/voice_pack_states.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/widgets/category_progress.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/widgets/instruction_card.dart';

/// Voice pack workspace: pack details, progress, category navigation, and the
/// instruction list.
class VoicePackWorkspacePage extends ConsumerStatefulWidget {
  const VoicePackWorkspacePage({super.key, required this.packId});

  final String packId;

  @override
  ConsumerState<VoicePackWorkspacePage> createState() =>
      _VoicePackWorkspacePageState();
}

class _VoicePackWorkspacePageState extends ConsumerState<VoicePackWorkspacePage> {
  InstructionCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Trigger the load once; the notifier is keyed by pack id via the family
    // argument, so navigating between packs reloads correctly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workspaceProvider.notifier).load(widget.packId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workspaceProvider);
    return AppShell(
      title: 'Voice Pack',
      subtitle: 'Workspace',
      child: _buildBody(state),
    );
  }

  Widget _buildBody(WorkspaceState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _Message(message: state.error!);
    }
    final pack = state.pack!;
    final progress = state.progress!;

    final visibleInstructions = _selectedCategory == null
        ? state.instructions
        : state.instructions
            .where((i) => i.category == _selectedCategory)
            .toList();

    return ListView(
      children: [
        Text(pack.name.value, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${pack.language.label} • ${pack.voice.label} • ${pack.personality.label}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProgressHeader(progress: progress),
        const SizedBox(height: AppSpacing.lg),
        CategoryProgress(
          instructions: state.instructions,
          selectedCategory: _selectedCategory,
          onSelected: (category) => setState(() {
            _selectedCategory =
                _selectedCategory == category ? null : category;
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final instruction in visibleInstructions) ...[
          InstructionCard(
            instruction: instruction,
            onTap: () => context.push(
              AppRoutes.instructionPath(widget.packId, instruction.id.value),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (visibleInstructions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No instructions in this category yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.tonalIcon(
          onPressed: () => context.push(AppRoutes.exportPath(widget.packId)),
          icon: const Icon(Icons.archive),
          label: const Text('Export Voice Pack'),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
