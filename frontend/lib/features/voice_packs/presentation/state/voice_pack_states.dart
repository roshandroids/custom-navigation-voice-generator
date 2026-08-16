import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';

/// Home screen state: the list of existing voice packs, or an error.
final class HomeState {
  const HomeState({
    required this.isLoading,
    required this.packs,
    this.error,
  });

  const HomeState.loading() : this(isLoading: true, packs: const []);

  HomeState.data(List<VoicePack> packs)
      : this(isLoading: false, packs: List.unmodifiable(packs));

  const HomeState.failure(String message)
      : this(isLoading: false, packs: const [], error: message);

  final bool isLoading;
  final List<VoicePack> packs;
  final String? error;
}

/// The workspace screen state: the voice pack and its instructions.
final class WorkspaceState {
  const WorkspaceState({
    required this.isLoading,
    this.pack,
    this.instructions = const [],
    this.progress,
    this.error,
  });

  const WorkspaceState.loading() : this(isLoading: true);

  WorkspaceState.data({
    required this.pack,
    required List<Instruction> instructions,
    required this.progress,
  })  : isLoading = false,
        instructions = List.unmodifiable(instructions),
        error = null;

  const WorkspaceState.failure(String message)
      : this(isLoading: false, error: message);

  final bool isLoading;
  final VoicePack? pack;
  final List<Instruction> instructions;
  final VoicePackProgress? progress;
  final String? error;
}
