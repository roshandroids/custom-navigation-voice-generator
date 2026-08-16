/// Supported voice pack languages.
///
/// A voice pack is single-language (see the `voice-pack-single-language`
/// decision): every instruction in a pack uses one language and one voice.
enum VoiceLanguage {
  nepali('Nepali'),
  english('English');

  const VoiceLanguage(this.label);

  final String label;

  static VoiceLanguage fromCode(String code) {
    switch (code) {
      case 'ne':
        return VoiceLanguage.nepali;
      case 'en':
        return VoiceLanguage.english;
      default:
        throw ArgumentError.value(code, 'code', 'Unknown language code');
    }
  }
}
