import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';

/// Progress toward recording all instructions of a voice pack.
///
/// Enforces the invariant that recorded never exceeds total, and defines the
/// completion rule (all instructions recorded).
final class VoicePackProgress {
  const VoicePackProgress._({required this.recorded, required this.total});

  final int recorded;
  final int total;

  /// 0 when there is nothing to record; otherwise recorded / total.
  double get fraction => total == 0 ? 0 : recorded / total;

  bool get isComplete => total > 0 && recorded >= total;

  static Result<VoicePackProgress> create({
    required int recorded,
    required int total,
  }) {
    if (recorded < 0 || total < 0) {
      return const Err(ValidationFailure('Counts cannot be negative.'));
    }
    if (recorded > total) {
      return const Err(
        ValidationFailure('Recorded count cannot exceed the total.'),
      );
    }
    return Ok(VoicePackProgress._(recorded: recorded, total: total));
  }
}
