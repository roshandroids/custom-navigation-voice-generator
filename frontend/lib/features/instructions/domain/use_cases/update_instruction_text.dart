import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction.dart';
import 'package:navigation_voice_generator/features/instructions/domain/repositories/instruction_repository.dart';
import 'package:navigation_voice_generator/features/instructions/domain/value_objects/instruction_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';

/// Persists the user's custom instruction text.
///
/// The UI keeps a local draft while typing; this use case is the explicit
/// save action.
class UpdateInstructionText {
  const UpdateInstructionText(this._repository);

  final InstructionRepository _repository;

  Future<Result<Instruction>> execute({
    required VoicePackId packId,
    required InstructionId instructionId,
    required String text,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return Future.value(
        const Err(ValidationFailure('Instruction text cannot be empty.')),
      );
    }
    return _repository.updateCustomText(
      packId: packId,
      id: instructionId,
      text: text,
    );
  }
}
