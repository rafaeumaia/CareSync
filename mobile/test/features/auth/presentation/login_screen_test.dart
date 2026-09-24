import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/features/auth/presentation/login_screen.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: RoutePaths.login,
      routes: [
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RoutePaths.dashboard,
          builder: (context, state) =>
              const Scaffold(body: Text('Dashboard stub')),
        ),
        GoRoute(
          path: RoutePaths.signup,
          builder: (context, state) =>
              const Scaffold(body: Text('Signup stub')),
        ),
      ],
    );

Future<void> _pumpLogin(
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

Finder _field(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    );

void main() {
  testWidgets('Mostra os textos, labels e placeholders do protótipo',
      (tester) async {
    await _pumpLogin(tester);

    for (final text in [
      'CareSync',
      'Cuidar com organização é cuidar melhor.',
      'E-mail',
      'Senha',
      'seu@email.com',
      '••••••••',
      'Esqueci minha senha',
      'Entrar',
      'Não tem uma conta? ',
      'Criar conta',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('Campos aceitam texto e a senha fica oculta', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(_field('E-mail'), 'ana@exemplo.com');
    await tester.enterText(_field('Senha'), 'segredo');
    await tester.pump();

    expect(find.text('ana@exemplo.com'), findsOneWidget);
    final password = tester.widget<TextField>(_field('Senha'));
    expect(password.obscureText, isTrue);
    expect(password.controller!.text, 'segredo');
    expect(tester.widget<TextField>(_field('E-mail')).keyboardType,
        TextInputType.emailAddress);
  });

  testWidgets('Foco não herda a borda interna do inputDecorationTheme',
      (tester) async {
    await _pumpLogin(tester);

    await tester.tap(_field('E-mail'));
    await tester.pump();

    final decoration = tester
        .widget<InputDecorator>(find.descendant(
            of: _field('E-mail'), matching: find.byType(InputDecorator)))
        .decoration;
    expect(decoration.focusedBorder, InputBorder.none);
    expect(decoration.enabledBorder, InputBorder.none);
    expect(decoration.filled, isFalse);
  });

  testWidgets('Entrar com e-mail válido e senha vai para o Dashboard',
      (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(_field('E-mail'), 'qualquer@coisa.com');
    await tester.enterText(_field('Senha'), 'x');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard stub'), findsOneWidget);
  });

  testWidgets('Enviar pelo teclado (senha) também entra', (tester) async {
    await _pumpLogin(tester);

    await tester.enterText(_field('E-mail'), 'a@b');
    await tester.enterText(_field('Senha'), '123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Dashboard stub'), findsOneWidget);
  });

  testWidgets('Campos vazios ou e-mail inválido bloqueiam o envio (required)',
      (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
        tester.widget<TextField>(_field('E-mail')).focusNode!.hasFocus, isTrue);

    await tester.enterText(_field('E-mail'), 'sem-arroba');
    await tester.enterText(_field('Senha'), '123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(_field('E-mail'), 'ok@exemplo.com');
    await tester.enterText(_field('Senha'), '');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
        tester.widget<TextField>(_field('Senha')).focusNode!.hasFocus, isTrue);
  });

  testWidgets('"Esqueci minha senha" não navega (sem ação no protótipo)',
      (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('"Criar conta" vai para o Signup', (tester) async {
    await _pumpLogin(tester);

    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.text('Signup stub'), findsOneWidget);
  });

  testWidgets('Tela pequena e teclado aberto: sem overflow', (tester) async {
    await _pumpLogin(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    // Simula o teclado ocupando ~300px da tela.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('Validação de e-mail segue a regra do HTML', () {
    expect(isValidHtmlEmail('a@b'), isTrue);
    expect(isValidHtmlEmail(' ana@exemplo.com '), isTrue);
    expect(isValidHtmlEmail(''), isFalse);
    expect(isValidHtmlEmail('ana'), isFalse);
    expect(isValidHtmlEmail('ana@'), isFalse);
    expect(isValidHtmlEmail('a b@c.com'), isFalse);
  });
}
