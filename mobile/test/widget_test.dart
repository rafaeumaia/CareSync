import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/main.dart';
import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/features/auth/presentation/login_screen.dart';
import 'package:caresync/features/auth/presentation/onboarding_screen.dart';

void main() {
  testWidgets('App inicia na Splash e aplica o tema do CareSync',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CareSyncApp()),
    );
    // A Splash tem uma animação de pulso infinita (`repeat`), então usamos
    // `pump` com uma duração limitada em vez de `pumpAndSettle`.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('CareSync'), findsWidgets);

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp).first,
    );
    expect(materialApp.title, 'CareSync');
  });

  testWidgets('Fluxo real do app: Splash -> Onboarding -> Login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CareSyncApp()),
    );
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Organize a rotina com facilidade'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('RoutePaths.splash é a rota inicial esperada',
      (WidgetTester tester) async {
    expect(RoutePaths.splash, '/splash');
  });
}
