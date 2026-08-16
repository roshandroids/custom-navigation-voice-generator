import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/app/app.dart';

void main() {
  Widget app() => const ProviderScope(child: CustomNavApp());

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
