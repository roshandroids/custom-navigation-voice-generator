import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/di/use_case_providers.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

/// Form state for creating a voice pack.
final class CreateVoicePackFormState {
  const CreateVoicePackFormState({
    required this.name,
    required this.language,
    required this.voice,
    required this.personality,
    this.isSubmitting = false,
    this.errorMessage,
  });

  CreateVoicePackFormState.initial()
      : this(
          name: '',
          language: VoiceLanguage.nepali,
          voice: VoiceCatalog.defaultFor(VoiceLanguage.nepali),
          personality: Personality.normal,
        );

  final String name;
  final VoiceLanguage language;
  final VoiceProfile voice;
  final Personality personality;
  final bool isSubmitting;
  final String? errorMessage;

  CreateVoicePackFormState copyWith({
    String? name,
    VoiceLanguage? language,
    VoiceProfile? voice,
    Personality? personality,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CreateVoicePackFormState(
        name: name ?? this.name,
        language: language ?? this.language,
        voice: voice ?? this.voice,
        personality: personality ?? this.personality,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

/// Coordinates the create-voice-pack form: draft fields, validation, and
/// dispatching the [CreateVoicePack] use case.
class CreateVoicePackNotifier extends Notifier<CreateVoicePackFormState> {
  @override
  CreateVoicePackFormState build() => CreateVoicePackFormState.initial();

  void updateName(String value) => state = state.copyWith(name: value);

  void updateLanguage(VoiceLanguage language) {
    state = state.copyWith(
      language: language,
      voice: VoiceCatalog.defaultFor(language),
    );
  }

  void updateVoice(VoiceProfile voice) => state = state.copyWith(voice: voice);

  void updatePersonality(Personality personality) =>
      state = state.copyWith(personality: personality);

  /// Validates and dispatches the create use case. Returns the created pack
  /// on success (so the router can navigate to it), or null on failure.
  Future<VoicePack?> create() async {
    final nameResult = VoicePackName.create(state.name);
    if (nameResult.isErr) {
      state = state.copyWith(
        errorMessage: (nameResult as Err<VoicePackName>).failure.message,
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    final pack = VoicePack(
      id: VoicePackId(_newId()),
      name: (nameResult as Ok<VoicePackName>).value,
      language: state.language,
      voice: state.voice,
      personality: state.personality,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(createVoicePackProvider).execute(pack);
    state = state.copyWith(isSubmitting: false);
    if (result.isErr) {
      state = state.copyWith(errorMessage: 'Could not create the voice pack.');
      return null;
    }
    return (result as Ok<VoicePack>).value;
  }

  String _newId() => 'pack-${DateTime.now().microsecondsSinceEpoch}';
}
