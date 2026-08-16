/// The category of a navigation instruction.
///
/// Mirrors the corpus categories from the benchmark. `languageTests` holds
/// personality/experiment phrases in the corpus but is not part of the
/// consumer-facing category set, so it is not a member here.
enum InstructionCategory {
  directions('Directions'),
  distances('Distances'),
  traffic('Traffic'),
  enforcement('Enforcement'),
  arrival('Arrival');

  const InstructionCategory(this.label);

  final String label;

  static InstructionCategory? fromCorpus(String value) {
    for (final category in InstructionCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }
}
