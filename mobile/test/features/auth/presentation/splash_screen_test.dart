import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/features/auth/presentation/splash_screen.dart';

void main() {
  testWidgets('Splash mostra o logo, o título e o slogan do protótipo',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump();

    expect(find.text('CareSync'), findsOneWidget);
    expect(find.text('Cuidar com organização'), findsOneWidget);
  });

  testWidgets('Splash navega automaticamente para /onboarding após 2s',
      (tester) async {
    final router = GoRouter(
      initialLocation: RoutePaths.splash,
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) =>
              const Scaffold(body: Text('Onboarding stub')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('CareSync'), findsOneWidget);

    // Pouco antes do prazo: ainda não deve ter navegado.
    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('CareSync'), findsOneWidget);

    // Atinge os 2s do protótipo original.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding stub'), findsOneWidget);
    expect(find.text('CareSync'), findsNothing);
  });

  testWidgets('Timer de navegação não dispara erro se a tela for descartada',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
  });
}
