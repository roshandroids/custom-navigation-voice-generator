import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/app_shell.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/generation_button.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/progress_header.dart';
import 'package:navigation_voice_generator/core/design_system/widgets/status_badge.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/voice_packs/domain/value_objects/voice_pack_progress.dart';
import 'package:navigation_voice_generator/core/result/result.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: buildAppTheme(), home: child);

  group('ProgressHeader', () {
    testWidgets('shows recorded/total and percent', (tester) async {
      final progress = (VoicePackProgress.create(recorded: 12, total: 25) as Ok<VoicePackProgress>).value;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ProgressHeader(progress: progress),
            ),
          ),
        ),
      );

      expect(find.text('12 / 25 recorded'), findsOneWidget);
      expect(find.text('48%'), findsOneWidget);
    });
  });

  group('StatusBadge', () {
    testWidgets('shows the label', (tester) async {
      await tester.pumpWidget(wrap(const Scaffold(body: StatusBadge(label: 'Recorded'))));
      expect(find.text('Recorded'), findsOneWidget);
    });
  });

  group('GenerationButton', () {
    testWidgets('shows label and fires callback', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: GenerationButton(
              label: 'Create Voice Pack',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create Voice Pack'));
      expect(pressed, isTrue);
    });

    testWidgets('disables while loading', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Scaffold(
            body: GenerationButton(
              label: 'Generate Audio',
              onPressed: _noop,
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });

  group('AppShell', () {
    testWidgets('shows title and subtitle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppShell(
            title: 'CustomNav',
            subtitle: 'Create your own navigation voice.',
            child: Text('content'),
          ),
        ),
      );

      expect(find.text('CustomNav'), findsOneWidget);
      expect(find.text('Create your own navigation voice.'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
    });
  });
}

void _noop() {}
