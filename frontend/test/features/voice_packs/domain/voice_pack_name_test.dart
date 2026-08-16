import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/error/failures.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';

void main() {
  group('VoicePackName.create', () {
    test('accepts a trimmed non-empty name', () {
      final result = VoicePackName.create('  My Nepali Voice  ');
      expect(result.isOk, isTrue);
      expect((result as Ok<VoicePackName>).value.value, 'My Nepali Voice');
    });

    test('rejects an empty name', () {
      final result = VoicePackName.create('   ');
      expect(result.isOk, isFalse);
      expect((result as Err<VoicePackName>).failure, isA<ValidationFailure>());
    });

    test('rejects a name longer than the maximum length', () {
      final result = VoicePackName.create('x' * (VoicePackName.maxLength + 1));
      expect(result.isOk, isFalse);
      expect((result as Err<VoicePackName>).failure, isA<ValidationFailure>());
    });

    test('accepts a name of exactly the maximum length', () {
      final result = VoicePackName.create('x' * VoicePackName.maxLength);
      expect(result.isOk, isTrue);
    });
  });
}
