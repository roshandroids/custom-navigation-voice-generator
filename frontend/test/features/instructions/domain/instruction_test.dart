import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/tts/domain/entities/audio_asset.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

void main() {
  Instruction baseInstruction() => const Instruction(
        id: InstructionId('turn_left_001'),
        packId: VoicePackId('pack-1'),
        category: InstructionCategory.directions,
        situation: 'बायाँ मोड',
        standardText: 'देब्रे मोड्नुहोस्।',
        customText: 'देब्रे मोड्नुहोस्।',
      );

  group('Instruction initial state', () {
    test('starts with standard text, no audio, not recorded', () {
      final instruction = baseInstruction();
      expect(instruction.customText, instruction.standardText);
      expect(instruction.isCustomized, isFalse);
      expect(instruction.audio, isNull);
      expect(instruction.isRecorded, isFalse);
    });
  });

  group('Instruction generated state', () {
    test('withCustomText marks the instruction as customized', () {
      final updated = baseInstruction().withCustomText('ल, देब्रे मोड्नुहोस् है।');
      expect(updated.customText, 'ल, देब्रे मोड्नुहोस् है।');
      expect(updated.isCustomized, isTrue);
      expect(updated.isRecorded, isFalse);
    });

    test('withAudio attaches generated audio', () {
      final asset = AudioAsset(
        id: const AudioAssetId('audio-1'),
        duration: const Duration(seconds: 4),
        format: AudioFormat.wav,
        kind: AudioKind.clean,
      );
      final generated = baseInstruction().withAudio(asset);
      expect(generated.audio, asset);
      expect(generated.hasCustomAudio, isTrue);
    });
  });

  group('Instruction recorded state', () {
    test('asRecorded marks the instruction recorded without losing content', () {
      final recorded = baseInstruction().withCustomText('ल, देब्रे मोड्नुहोस् है।').asRecorded();
      expect(recorded.isRecorded, isTrue);
      expect(recorded.customText, 'ल, देब्रे मोड्नुहोस् है।');
    });
  });
}
