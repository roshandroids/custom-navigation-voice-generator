import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/state/voice_pack_states.dart';

/// Loads the voice pack list for the home screen.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    _load();
    return const HomeState.loading();
  }

  Future<void> _load() async {
    final result = await ref.read(getVoicePacksProvider).execute();
    if (result.isErr) {
      state = HomeState.failure('Could not load voice packs.');
      return;
    }
    state = HomeState.data((result as Ok<List<VoicePack>>).value);
  }
}
