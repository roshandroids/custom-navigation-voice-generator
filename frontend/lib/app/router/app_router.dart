import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation_voice_generator/features/export/presentation/pages/export_page.dart';
import 'package:navigation_voice_generator/features/instructions/presentation/pages/instruction_editor_page.dart';
import 'package:navigation_voice_generator/features/recording/presentation/pages/recording_page.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/pages/create_voice_pack_page.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/pages/home_page.dart';
import 'package:navigation_voice_generator/features/voice_packs/presentation/pages/voice_pack_workspace_page.dart';

/// Central routing table.
///
/// Routes live in the app layer — feature code never owns the router.
abstract final class AppRoutes {
  static const home = '/';
  static const create = '/create';
  static const pack = '/pack/:id';
  static const instruction = '/pack/:id/instruction/:instructionId';
  static const record = '/pack/:id/record/:instructionId';
  static const export = '/pack/:id/export';

  static String packPath(String id) => '/pack/$id';
  static String instructionPath(String packId, String instructionId) =>
      '/pack/$packId/instruction/$instructionId';
  static String recordPath(String packId, String instructionId) =>
      '/pack/$packId/record/$instructionId';
  static String exportPath(String packId) => '/pack/$packId/export';
}

/// Builds the app router. Invalid ids are handled gracefully by the pages
/// (each page resolves its params through providers and shows an error state
/// when the pack or instruction does not exist).
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const CreateVoicePackPage(),
      ),
      GoRoute(
        path: AppRoutes.pack,
        builder: (context, state) => VoicePackWorkspacePage(
          packId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.instruction,
        builder: (context, state) => InstructionEditorPage(
          packId: state.pathParameters['id']!,
          instructionId: state.pathParameters['instructionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.record,
        builder: (context, state) => RecordingPage(
          packId: state.pathParameters['id']!,
          instructionId: state.pathParameters['instructionId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.export,
        builder: (context, state) => ExportPage(
          packId: state.pathParameters['id']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('This page does not exist.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
