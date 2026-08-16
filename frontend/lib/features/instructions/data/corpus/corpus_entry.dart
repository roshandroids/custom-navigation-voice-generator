import 'package:navigation_voice_generator/features/instructions/domain/entities/instruction_category.dart';

/// A corpus entry for seeding mock repositories.
///
/// The sample corpus mirrors the structure of the finalized benchmark corpora
/// (`benchmark/corpus/phrases.json`, `phrases_en.json`). The app never reads
/// those files at runtime — it uses a curated subset as sample content so the
/// frontend can run without Python.
class CorpusEntry {
  const CorpusEntry({
    required this.id,
    required this.category,
    required this.situation,
    required this.text,
  });

  final String id;
  final InstructionCategory category;
  final String situation;
  final String text;
}
