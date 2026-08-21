import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/app.dart';
import 'package:navigation_voice_generator/app/di/providers.dart';
import 'package:navigation_voice_generator/core/result/result.dart';
import 'package:navigation_voice_generator/features/export/data/repositories/mock_export_repository.dart';
import 'package:navigation_voice_generator/features/instructions/data/repositories/in_memory_instruction_repository.dart';
import 'package:navigation_voice_generator/features/suggestions/data/repositories/mock_suggestion_repository.dart';
import 'package:navigation_voice_generator/features/tts/data/repositories/mock_tts_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/data/repositories/in_memory_voice_pack_repository.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/entities/voice_pack.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/personality.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_language.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_id.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_name.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_profile.dart';

void main() {
  ProviderContainer fakeContainer() {
    final packs = InMemoryVoicePackRepository();
    packs.create(
      VoicePack(
        id: const VoicePackId('seed-ne'),
        name: (VoicePackName.create('My Nepali Voice') as Ok<VoicePackName>).value,
        language: VoiceLanguage.nepali,
        voice: VoiceCatalog.nepali.first,
        personality: Personality.savage,
        createdAt: DateTime(2026, 8, 15),
      ),
    );
    packs.create(
      VoicePack(
        id: const VoicePackId('seed-en'),
        name: (VoicePackName.create('English Daily') as Ok<VoicePackName>).value,
        language: VoiceLanguage.english,
        voice: VoiceCatalog.english.first,
        personality: Personality.normal,
        createdAt: DateTime(2026, 8, 14),
      ),
    );
    return ProviderContainer(
      overrides: [
        voicePackRepositoryProvider.overrideWithValue(packs),
        instructionRepositoryProvider
            .overrideWithValue(InMemoryInstructionRepository.seeded()),
        ttsRepositoryProvider.overrideWithValue(MockTtsRepository()),
        suggestionRepositoryProvider.overrideWithValue(MockSuggestionRepository()),
        exportRepositoryProvider.overrideWithValue(MockExportRepository()),
      ],
    );
  }

  Widget app() => UncontrolledProviderScope(
        container: fakeContainer(),
        child: const CustomNavApp(),
      );

  Future<void> settle(WidgetTester tester) async {
    // The home/workspace screens show indeterminate progress indicators
    // while providers load, so pumpAndSettle would time out. Pump a few
    // frames instead to let the initial async loads resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('home route renders the brand', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    expect(find.text('CustomNav'), findsOneWidget);
  });

  testWidgets('create route is reachable from home', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    await tester.tap(find.text('Create Voice Pack').first);
    await settle(tester);

    expect(find.text('Create Voice Pack'), findsWidgets);
    expect(find.text('Name'), findsOneWidget);
  });

  testWidgets('invalid route shows the error page', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    // Drive the app's own router from a context inside the router scope.
    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/does/not/exist');
    await settle(tester);

    expect(find.text('This page does not exist.'), findsOneWidget);
  });

  testWidgets('seed pack workspace is reachable', (tester) async {
    await tester.pumpWidget(app());
    await settle(tester);

    // The seeded Nepali pack appears on home; open it.
    await tester.tap(find.text('My Nepali Voice'));
    await settle(tester);

    expect(find.text('Workspace'), findsWidgets);
  });
}
