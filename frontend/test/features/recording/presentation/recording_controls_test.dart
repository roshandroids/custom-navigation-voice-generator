import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';
import 'package:navigation_voice_generator/features/recording/domain/value_objects/recording_state.dart';
import 'package:navigation_voice_generator/features/recording/presentation/widgets/recording_controls.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: buildAppTheme(), home: Scaffold(body: child));

  group('RecordingControls', () {
    testWidgets('shows Enter Recording Mode only in idle', (tester) async {
      var prepared = false;
      await tester.pumpWidget(
        wrap(
          RecordingControls(
            phase: RecordingPhase.idle,
            onPrepare: () => prepared = true,
            onMarkRecorded: () {},
            onReplay: () {},
            onNext: () {},
            onPrevious: () {},
          ),
        ),
      );

      expect(find.text('Enter Recording Mode'), findsOneWidget);
      expect(find.text('Mark Recorded'), findsNothing);

      await tester.tap(find.text('Enter Recording Mode'));
      expect(prepared, isTrue);
    });

    testWidgets('shows Mark Recorded only in completed', (tester) async {
      var recorded = false;
      await tester.pumpWidget(
        wrap(
          RecordingControls(
            phase: RecordingPhase.completed,
            onPrepare: () {},
            onMarkRecorded: () => recorded = true,
            onReplay: () {},
            onNext: () {},
            onPrevious: () {},
          ),
        ),
      );

      expect(find.text('Mark Recorded'), findsOneWidget);
      expect(find.text('Enter Recording Mode'), findsNothing);

      await tester.tap(find.text('Mark Recorded'));
      expect(recorded, isTrue);
    });

    testWidgets('shows Replay after recorded', (tester) async {
      var replayed = false;
      await tester.pumpWidget(
        wrap(
          RecordingControls(
            phase: RecordingPhase.recorded,
            onPrepare: () {},
            onMarkRecorded: () {},
            onReplay: () => replayed = true,
            onNext: () {},
            onPrevious: () {},
          ),
        ),
      );

      expect(find.text('Replay'), findsOneWidget);
      await tester.tap(find.text('Replay'));
      expect(replayed, isTrue);
    });

    testWidgets('shows Next after recorded when available', (tester) async {
      await tester.pumpWidget(
        wrap(
          RecordingControls(
            phase: RecordingPhase.recorded,
            onPrepare: () {},
            onMarkRecorded: () {},
            onReplay: () {},
            onNext: () {},
            onPrevious: () {},
            hasNext: true,
          ),
        ),
      );

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('hides Next on the final instruction', (tester) async {
      await tester.pumpWidget(
        wrap(
          RecordingControls(
            phase: RecordingPhase.recorded,
            onPrepare: () {},
            onMarkRecorded: () {},
            onReplay: () {},
            onNext: () {},
            onPrevious: () {},
            hasNext: false,
          ),
        ),
      );

      expect(find.text('Next'), findsNothing);
    });
  });
}
