import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';

/// A validated voice pack name.
///
/// Enforces a meaningful business rule: the name must be non-empty after
/// trimming and no longer than [maxLength] characters.
final class VoicePackName {
  const VoicePackName._(this.value);

  static const int maxLength = 40;

  final String value;

  static Result<VoicePackName> create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationFailure('Name cannot be empty.'));
    }
    if (trimmed.length > maxLength) {
      return Err(
        ValidationFailure('Name cannot be longer than $maxLength characters.'),
      );
    }
    return Ok(VoicePackName._(trimmed));
  }

  @override
  bool operator ==(Object other) => other is VoicePackName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'VoicePackName($value)';
}
