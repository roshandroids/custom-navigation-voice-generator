import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/state/voice_pack_states.dart';

/// Loads a voice pack and its instructions for the workspace screen.
class WorkspaceNotifier extends Notifier<WorkspaceState> {
  @override
  WorkspaceState build() => const WorkspaceState.loading();

  Future<void> load(String packId) async {
    state = const WorkspaceState.loading();

    final packResult = await ref
        .read(getVoicePackProvider)
        .execute(VoicePackId(packId));
    if (packResult.isErr) {
      state = WorkspaceState.failure(_messageFor(packResult));
      return;
    }
    final pack = (packResult as Ok).value;

    final instructionsResult =
        await ref.read(getInstructionsProvider).execute(pack.id);
    if (instructionsResult.isErr) {
      state = WorkspaceState.failure(_messageFor(instructionsResult));
      return;
    }
    final instructions = (instructionsResult as Ok).value;

    final progressResult =
        await ref.read(getVoicePackProgressProvider).execute(pack.id);
    if (progressResult.isErr) {
      state = WorkspaceState.failure(_messageFor(progressResult));
      return;
    }

    state = WorkspaceState.data(
      pack: pack,
      instructions: instructions,
      progress: (progressResult as Ok).value,
    );
  }
}

String _messageFor(Result result) {
  final failure = result is Err ? result.failure : const UnexpectedFailure('Unknown error.');
  return _friendlyMessage(failure);
}

String _friendlyMessage(Failure failure) => switch (failure) {
      ValidationFailure(:final message) => message,
      NotFoundFailure() => 'Not found.',
      _ => 'Something went wrong.',
    };
