import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// A navigation situation with its standard instruction and the user's
/// customized instruction.
///
/// The instruction lifecycle is: initial (custom == standard) → generated
/// (custom text + optional audio) → recorded.
final class Instruction {
  const Instruction({
    required this.id,
    required this.packId,
    required this.category,
    required this.situation,
    required this.standardText,
    required this.customText,
    this.audio,
    this.isRecorded = false,
  });

  final InstructionId id;
  final VoicePackId packId;
  final InstructionCategory category;

  /// Short human label of the navigation situation, e.g. "बायाँ मोड".
  final String situation;

  /// The standard navigation instruction shown by the app.
  final String standardText;

  /// The user's (possibly customized) instruction.
  final String customText;

  /// Generated audio for [customText], when it exists.
  final AudioAsset? audio;

  final bool isRecorded;

  bool get isCustomized => customText.trim() != standardText.trim();

  bool get hasCustomAudio => audio != null;

  Instruction withCustomText(String text) => Instruction(
        id: id,
        packId: packId,
        category: category,
        situation: situation,
        standardText: standardText,
        customText: text,
        audio: audio,
        isRecorded: isRecorded,
      );

  Instruction withAudio(AudioAsset asset) => Instruction(
        id: id,
        packId: packId,
        category: category,
        situation: situation,
        standardText: standardText,
        customText: customText,
        audio: asset,
        isRecorded: isRecorded,
      );

  Instruction asRecorded() => Instruction(
        id: id,
        packId: packId,
        category: category,
        situation: situation,
        standardText: standardText,
        customText: customText,
        audio: audio,
        isRecorded: true,
      );
}
