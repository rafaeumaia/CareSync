import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/features/auth/presentation/login_screen.dart';
import 'package:caresync/features/auth/presentation/onboarding_screen.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: RoutePaths.onboarding,
      routes: [
        GoRoute(
          path: RoutePaths.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
      ],
    );

/// Viewport de celular (390x844, iPhone 12-15) por padrão.
Future<void> _pumpOnboarding(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light, routerConfig: _buildRouter()),
  );
  await tester.pumpAndSettle();
}

double _dotWidth(WidgetTester tester, int index) => tester
    .getSize(find.byKey(ValueKey('onboarding-dot-$index')))
    .width;

void main() {
  testWidgets('Percorre os 3 slides com os textos originais e conclui no Login',
      (tester) async {
    await _pumpOnboarding(tester);

    for (var i = 0; i < onboardingSlides.length; i++) {
      final slide = onboardingSlides[i];
      expect(find.text(slide.title), findsOneWidget);
      expect(find.text(slide.description), findsOneWidget);
      for (var d = 0; d < onboardingSlides.length; d++) {
        expect(_dotWidth(tester, d), d == i ? 32 : 8);
      }

      final isLast = i == onboardingSlides.length - 1;
      expect(find.text('Próximo'), isLast ? findsNothing : findsOneWidget);
      expect(find.text('Começar'), isLast ? findsOneWidget : findsNothing);
      expect(find.text('Pular'), isLast ? findsNothing : findsOneWidget);

      await tester.tap(find.text(isLast ? 'Começar' : 'Próximo'));
      await tester.pumpAndSettle();
    }

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Textos dos slides batem com o protótipo', (tester) async {
    expect(onboardingSlides.map((s) => s.title), [
      'Organize a rotina com facilidade',
      'Monitore consultas, medicamentos e saúde',
      'Conecte-se à família e garanta bem-estar',
    ]);
    expect(onboardingSlides.map((s) => s.description), [
      'Gerencie consultas, medicamentos e horários de forma simples e intuitiva.',
      'Acompanhe indicadores vitais e mantenha o histórico médico sempre atualizado.',
      'Compartilhe informações importantes e cuide com segurança e carinho.',
    ]);
  });

  testWidgets('Pular no primeiro slide vai direto para o Login',
      (tester) async {
    await _pumpOnboarding(tester);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Pular no segundo slide também vai para o Login',
      (tester) async {
    await _pumpOnboarding(tester);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Tela pequena: sem overflow, rola até os botões de 48px',
      (tester) async {
    await _pumpOnboarding(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.widgetWithText(TextButton, 'Próximo')).height,
        48);
    expect(tester.getSize(find.widgetWithText(TextButton, 'Pular')).height,
        48);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
