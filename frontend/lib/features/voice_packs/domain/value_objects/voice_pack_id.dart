/// Identifier of a [VoicePack].
final class VoicePackId {
  const VoicePackId(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is VoicePackId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'VoicePackId($value)';
}
