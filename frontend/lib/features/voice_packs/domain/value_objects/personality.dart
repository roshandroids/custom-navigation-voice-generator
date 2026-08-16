import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';

/// The speaking personality of a voice pack.
///
/// Personality drives both the suggestion style and the example text shown
/// when a user is choosing a personality.
enum Personality {
  simple('Simple'),
  normal('Normal'),
  firm('Firm'),
  savage('Savage');

  const Personality(this.label);

  final String label;

  /// Short example of how this personality sounds, per language.
  ///
  /// These are sample/preview texts for the create flow — not production
  /// instruction content.
  String exampleFor(VoiceLanguage language) {
    switch (this) {
      case Personality.simple:
        if (language == VoiceLanguage.nepali) return 'देब्रे मोड्नुहोस्।';
        return 'Turn left.';
      case Personality.normal:
        if (language == VoiceLanguage.nepali) {
          return 'अगाडि देब्रेतिर मोड्नुहोस्।';
        }
        return 'Please turn left at the next street.';
      case Personality.firm:
        if (language == VoiceLanguage.nepali) {
          return 'अगाडि स्पिड क्यामेरा छ, बिस्तारै जानुहोस्।';
        }
        return 'Slow down. Speed camera ahead.';
      case Personality.savage:
        if (language == VoiceLanguage.nepali) {
          return 'ल, अगाडि स्पिड क्यामेरा छ है। अलि बिस्तारै जाऊ।';
        }
        return 'Speed camera ahead. Don\'t try to be a hero.';
    }
  }
}
