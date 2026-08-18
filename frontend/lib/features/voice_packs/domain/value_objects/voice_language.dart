/// Supported voice pack languages.
///
/// A voice pack is single-language (see the `voice-pack-single-language`
/// decision): every instruction in a pack uses one language and one voice.
enum VoiceLanguage {
  nepali('ne', 'Nepali'),
  english('en', 'English');

  const VoiceLanguage(this.code, this.label);

  /// ISO 639-1 language code used by the TTS service request body.
  final String code;
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
