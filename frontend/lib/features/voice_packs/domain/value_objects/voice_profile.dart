import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// A voice available for a voice pack.
///
/// These are configuration/sample voices for the MVP — not a final
/// production voice selection.
final class VoiceProfile {
  const VoiceProfile({
    required this.id,
    required this.language,
    required this.label,
  });

  final String id;
  final VoiceLanguage language;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is VoiceProfile && other.id == id && other.language == language;

  @override
  int get hashCode => Object.hash(id, language);

  @override
  String toString() => 'VoiceProfile($id)';
}

/// Catalog of the voices the MVP offers per language.
///
/// Nepali voices map to the Piper voices evaluated in the benchmark
/// (`ne_NP-chitwan`, `ne_NP-google`); English voices are the English corpus
/// voices (`en_US-joe`, `en_US-kristin`, `en_US-ljspeech`).
final class VoiceCatalog {
  const VoiceCatalog._();

  static const nepali = <VoiceProfile>[
    VoiceProfile(id: 'chitwan', language: VoiceLanguage.nepali, label: 'Chitwan'),
    VoiceProfile(id: 'google-medium', language: VoiceLanguage.nepali, label: 'Google Medium'),
    VoiceProfile(id: 'google-x-low', language: VoiceLanguage.nepali, label: 'Google X-Low'),
  ];

  static const english = <VoiceProfile>[
    VoiceProfile(id: 'joe', language: VoiceLanguage.english, label: 'Joe'),
    VoiceProfile(id: 'kristin', language: VoiceLanguage.english, label: 'Kristin'),
    VoiceProfile(id: 'ljspeech', language: VoiceLanguage.english, label: 'LJSpeech'),
  ];

  static List<VoiceProfile> forLanguage(VoiceLanguage language) =>
      switch (language) {
        VoiceLanguage.nepali => nepali,
        VoiceLanguage.english => english,
      };

  static VoiceProfile defaultFor(VoiceLanguage language) =>
      forLanguage(language).first;

  static VoiceProfile? byId(String id) => [
        ...nepali,
        ...english,
      ].where((v) => v.id == id).firstOrNull;
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
