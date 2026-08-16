/// Identifier of a navigation [Instruction].
final class InstructionId {
  const InstructionId(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is InstructionId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'InstructionId($value)';
}
