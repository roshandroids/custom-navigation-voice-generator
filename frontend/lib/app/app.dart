import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigation_voice_generator/app/router/app_router.dart';
import 'package:navigation_voice_generator/core/design_system/app_theme.dart';

/// Root widget: wires Riverpod + the router + the theme.
class CustomNavApp extends ConsumerWidget {
  const CustomNavApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'CustomNav',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
