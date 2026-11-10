import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/core/widgets/app_button.dart';
import 'package:caresync/features/auth/data/auth_repository.dart';
import 'package:caresync/features/auth/domain/signup.dart';
import 'package:caresync/features/auth/presentation/login_screen.dart';
import 'package:caresync/features/auth/presentation/signup_screen.dart';
import 'package:caresync/features/auth/presentation/widgets/signup_type_card.dart';
import 'package:caresync/features/auth/state/auth_providers.dart';

/// Guarda o que chegaria à API, sem armazenar nada além do teste. [onSignUp]
/// permite simular demora ou falha.
class _FakeAuthRepository implements AuthRepository {
  final requests = <SignupRequest>[];
  Future<void> Function()? onSignUp;

  @override
  Future<void> signUp(SignupRequest request) async {
    requests.add(request);
    await onSignUp?.call();
  }
}

const _termsText = 'Aceito os termos de uso e política de privacidade';

/// Abre o Login (para testar "Criar conta" de verdade) ou o Signup.
Future<_FakeAuthRepository> _pump(
  WidgetTester tester, {
  String initial = RoutePaths.signup,
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  final repository = _FakeAuthRepository();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(
        theme: theme ?? AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: initial,
          routes: [
            GoRoute(
              path: RoutePaths.login,
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: RoutePaths.signup,
              builder: (context, state) => const SignupScreen(),
            ),
            GoRoute(
              path: RoutePaths.dashboard,
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard stub')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

Finder _field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextField),
);

TextField _textField(WidgetTester tester, String label) =>
    tester.widget<TextField>(_field(label));

TextEditingController _controller(WidgetTester tester, String label) =>
    _textField(tester, label).controller!;

AppButton _cadastrar(WidgetTester tester) =>
    tester.widget<AppButton>(find.byType(AppButton));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _chooseType(WidgetTester tester, String title) =>
    _tap(tester, find.text(title));

Future<void> _fill(
  WidgetTester tester, {
  String name = 'Ana Souza',
  String email = 'ana@exemplo.com',
  String phone = '11988887777',
  String password = 'segredo12',
  String confirm = 'segredo12',
}) async {
  for (final (label, value) in [
    ('Nome completo', name),
    ('E-mail', email),
    ('Telefone', phone),
    ('Senha', password),
    ('Confirmar senha', confirm),
  ]) {
    await tester.enterText(_field(label), value);
  }
  await tester.pump();
}

/// Toca na caixa do aceite (o texto tem links).
Future<void> _acceptTerms(WidgetTester tester) =>
    _tap(tester, find.bySemanticsLabel(_termsText));

/// Toca no trecho [part] do texto do aceite.
Future<void> _tapTermsPart(WidgetTester tester, String part) async {
  final finder = find.byWidgetPredicate(
    (w) => w is RichText && w.text.toPlainText() == _termsText,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final start = _termsText.indexOf(part);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + part.length),
      )
      .first;
  await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
  await tester.pumpAndSettle();
}

Future<void> _submitValid(WidgetTester tester) async {
  await _fill(tester);
  await _acceptTerms(tester);
  await _tap(tester, find.text('Cadastrar'));
}

void main() {
  testWidgets('Login → "Criar conta" abre o Signup na etapa de perfil', (
    tester,
  ) async {
    await _pump(tester, initial: RoutePaths.login);

    await _tap(tester, find.text('Criar conta'));

    expect(find.byType(SignupScreen), findsOneWidget);
    expect(find.text('Escolha o tipo de perfil'), findsOneWidget);
  });

  testWidgets('Etapa 1: textos, 3 perfis, passo 1 de 2 e "Fazer login"', (
    tester,
  ) async {
    await _pump(tester);

    for (final text in [
      'Criar conta',
      'Escolha o tipo de perfil',
      'Passo 1 de 2',
      'Cuidador Profissional',
      'Para profissionais de saúde',
      'Cuidador Familiar',
      'Para familiares e amigos',
      'Responsável',
      'Para gerentes e administradores',
      'Já tem uma conta? ',
      'Fazer login',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byType(SignupTypeCard), findsNWidgets(3));

    await _tap(tester, find.text('Fazer login'));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Etapa 2: campos, passo 2 de 2 e "Cadastrar" desabilitado', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');

    for (final text in [
      'Criar conta',
      'Preencha seus dados',
      'Passo 2 de 2',
      'Nome completo',
      'Seu nome',
      'E-mail',
      'seu@email.com',
      'Telefone',
      '(00) 00000-0000',
      'Senha',
      'Confirmar senha',
      _termsText,
      'Cadastrar',
      '← Voltar',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('••••••••'), findsNWidgets(2));
    expect(_textField(tester, 'Senha').obscureText, isTrue);
    expect(_textField(tester, 'Confirmar senha').obscureText, isTrue);
    expect(
      _textField(tester, 'E-mail').keyboardType,
      TextInputType.emailAddress,
    );
    expect(_textField(tester, 'Telefone').keyboardType, TextInputType.phone);

    // "Cadastrar" só habilita com o aceite dos termos (e volta a desabilitar).
    expect(_cadastrar(tester).onPressed, isNull);
    await _acceptTerms(tester);
    expect(_cadastrar(tester).onPressed, isNotNull);
    // Tocar no texto fora dos links também alterna.
    await _tapTermsPart(tester, 'Aceito os');
    expect(_cadastrar(tester).onPressed, isNull);
  });

  testWidgets('Validações: obrigatórios, e-mail e foco no primeiro inválido', (
    tester,
  ) async {
    final repository = await _pump(tester);
    await _chooseType(tester, 'Cuidador Profissional');
    await _acceptTerms(tester);

    await _tap(tester, find.text('Cadastrar'));
    for (final text in [
      'Informe seu nome completo.',
      'Informe seu e-mail.',
      'Informe seu telefone.',
      'Informe uma senha.',
      'Confirme sua senha.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(_textField(tester, 'Nome completo').focusNode!.hasFocus, isTrue);
    expect(find.text('Cadastro realizado com sucesso! 💙'), findsNothing);

    // Os erros acompanham a digitação depois da primeira tentativa.
    await tester.enterText(_field('Nome completo'), '   ');
    await tester.pump();
    expect(find.text('Informe seu nome completo.'), findsOneWidget);
    await tester.enterText(_field('Nome completo'), 'Ana');
    await tester.pump();
    expect(find.text('Informe seu nome completo.'), findsNothing);

    await tester.enterText(_field('E-mail'), 'ana@');
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);

    await _tap(tester, find.text('Cadastrar'));
    expect(_textField(tester, 'E-mail').focusNode!.hasFocus, isTrue);
    expect(repository.requests, isEmpty);
  });

  testWidgets('Senha: mínimo de 8 caracteres e confirmação igual', (
    tester,
  ) async {
    final repository = await _pump(tester);
    await _chooseType(tester, 'Responsável');
    await _fill(tester, password: 'curta12', confirm: 'curta12');
    await _acceptTerms(tester);

    await _tap(tester, find.text('Cadastrar'));
    expect(
      find.text('A senha deve ter pelo menos 8 caracteres.'),
      findsOneWidget,
    );
    expect(_textField(tester, 'Senha').focusNode!.hasFocus, isTrue);

    await tester.enterText(_field('Senha'), 'segredo12');
    await tester.pump();
    expect(
      find.text('A senha deve ter pelo menos 8 caracteres.'),
      findsNothing,
    );
    expect(find.text('As senhas não coincidem.'), findsOneWidget);

    await _tap(tester, find.text('Cadastrar'));
    expect(_textField(tester, 'Confirmar senha').focusNode!.hasFocus, isTrue);
    expect(repository.requests, isEmpty);

    await tester.enterText(_field('Confirmar senha'), 'segredo12');
    await tester.pump();
    expect(find.text('As senhas não coincidem.'), findsNothing);
  });

  testWidgets('Mostrar/ocultar cada senha de forma independente', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');

    await _tap(tester, find.bySemanticsLabel('Mostrar senha'));
    expect(_textField(tester, 'Senha').obscureText, isFalse);
    expect(_textField(tester, 'Confirmar senha').obscureText, isTrue);
    expect(find.bySemanticsLabel('Ocultar senha'), findsOneWidget);

    await _tap(tester, find.bySemanticsLabel('Mostrar confirmação de senha'));
    expect(_textField(tester, 'Confirmar senha').obscureText, isFalse);

    await _tap(tester, find.bySemanticsLabel('Ocultar senha'));
    expect(_textField(tester, 'Senha').obscureText, isTrue);
    expect(_textField(tester, 'Confirmar senha').obscureText, isFalse);
  });

  testWidgets('Telefone: máscara enquanto digita e DDD obrigatório', (
    tester,
  ) async {
    final repository = await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');

    await tester.enterText(_field('Telefone'), '11988887777');
    await tester.pump();
    expect(_controller(tester, 'Telefone').text, '(11) 98888-7777');

    await tester.enterText(_field('Telefone'), '1133334444');
    await tester.pump();
    expect(_controller(tester, 'Telefone').text, '(11) 3333-4444');

    await _fill(tester, phone: '988887');
    await _acceptTerms(tester);
    await _tap(tester, find.text('Cadastrar'));
    expect(find.text('Informe o telefone com DDD.'), findsOneWidget);
    expect(repository.requests, isEmpty);

    // Envia só os dígitos.
    await tester.enterText(_field('Telefone'), '(21) 99999-0000');
    await _tap(tester, find.text('Cadastrar'));
    expect(repository.requests.single.phone, '21999990000');
  });

  testWidgets('Links abrem os termos e a política sem alternar o aceite', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');

    await _tapTermsPart(tester, 'termos de uso');
    expect(find.text('Termos de uso'), findsOneWidget);
    expect(find.textContaining('ainda não foi publicado'), findsOneWidget);
    expect(_cadastrar(tester).onPressed, isNull);
    await tester.tap(find.bySemanticsLabel('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Termos de uso'), findsNothing);

    await _tapTermsPart(tester, 'política de privacidade');
    expect(find.text('Política de privacidade'), findsOneWidget);
    expect(_cadastrar(tester).onPressed, isNull);
  });

  testWidgets('Voltar preserva os campos e o aceite, mesmo trocando o perfil', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseType(tester, 'Cuidador Profissional');
    await _fill(tester);
    await _acceptTerms(tester);

    await _tap(tester, find.text('← Voltar'));
    expect(find.text('Escolha o tipo de perfil'), findsOneWidget);
    expect(find.text('Nome completo'), findsNothing);

    await _chooseType(tester, 'Cuidador Familiar');
    expect(_controller(tester, 'Nome completo').text, 'Ana Souza');
    expect(_controller(tester, 'E-mail').text, 'ana@exemplo.com');
    expect(_controller(tester, 'Telefone').text, '(11) 98888-7777');
    expect(_controller(tester, 'Senha').text, 'segredo12');
    expect(_controller(tester, 'Confirmar senha').text, 'segredo12');
    expect(_cadastrar(tester).onPressed, isNotNull);
  });

  testWidgets('Voltar do sistema: formulário → perfil → Login', (tester) async {
    await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');
    await tester.enterText(_field('Nome completo'), 'Ana');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Escolha o tipo de perfil'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Concluir → diálogo de sucesso → "Ir para o login"', (
    tester,
  ) async {
    final repository = await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');
    await _fill(tester, email: ' ana@exemplo.com ');
    await _acceptTerms(tester);

    await _tap(tester, find.text('Cadastrar'));

    final request = repository.requests.single;
    expect(request.tipo, TipoUsuario.familiar);
    expect(request.name, 'Ana Souza');
    expect(request.email, 'ana@exemplo.com');
    expect(request.phone, '11988887777');

    for (final text in [
      'Cadastro realizado com sucesso! 💙',
      'Bem-vindo ao CareSync. Agora você pode fazer login e começar a '
          'cuidar com organização.',
      'Ir para o login',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Nome completo'), findsNothing);

    // Tocar fora não fecha (`<Dialog open>` sem `onOpenChange`).
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Ir para o login'), findsOneWidget);

    await tester.tap(find.text('Ir para o login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SignupScreen), findsNothing);
  });

  testWidgets('Sucesso: o X e o voltar do sistema também levam ao Login', (
    tester,
  ) async {
    await _pump(tester);
    await _chooseType(tester, 'Responsável');
    await _submitValid(tester);

    await tester.tap(find.bySemanticsLabel('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await _tap(tester, find.text('Criar conta'));
    await _chooseType(tester, 'Responsável');
    // Voltar ao Login descarta o que foi preenchido.
    expect(_controller(tester, 'Nome completo').text, isEmpty);
    await _submitValid(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Carregamento: botão "Cadastrando..." e sem envio duplicado', (
    tester,
  ) async {
    final repository = await _pump(tester);
    final pending = Completer<void>();
    repository.onSignUp = () => pending.future;
    await _chooseType(tester, 'Cuidador Familiar');
    await _fill(tester);
    await _acceptTerms(tester);
    // O indicador gira enquanto espera: `pump` em vez de `pumpAndSettle`.
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Cadastrando...'), findsOneWidget);
    expect(_cadastrar(tester).loading, isTrue);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Cadastrando...'));
    await tester.pump();
    expect(repository.requests, hasLength(1));

    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ir para o login'), findsOneWidget);
  });

  testWidgets('Falhas: e-mail já cadastrado no campo, outras acima do botão', (
    tester,
  ) async {
    final repository = await _pump(tester);
    repository.onSignUp = () async =>
        throw const SignupFailure(SignupFailureReason.emailAlreadyRegistered);
    await _chooseType(tester, 'Cuidador Familiar');
    await _submitValid(tester);

    expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
    expect(_textField(tester, 'E-mail').focusNode!.hasFocus, isTrue);
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Ir para o login'), findsNothing);
    // Editar outro campo mantém o erro; trocar o e-mail o remove.
    await tester.enterText(_field('Nome completo'), 'Ana S.');
    await tester.pump();
    expect(find.text('Este e-mail já está cadastrado.'), findsOneWidget);
    await tester.enterText(_field('E-mail'), 'outra@exemplo.com');
    await tester.pump();
    expect(find.text('Este e-mail já está cadastrado.'), findsNothing);

    repository.onSignUp = () async =>
        throw const SignupFailure(SignupFailureReason.network);
    await _tap(tester, find.text('Cadastrar'));
    expect(
      find.text('Sem conexão com a internet. Verifique e tente novamente.'),
      findsOneWidget,
    );

    repository.onSignUp = () async => throw Exception('500');
    await _tap(tester, find.text('Cadastrar'));
    expect(
      find.text('Sem conexão com a internet. Verifique e tente novamente.'),
      findsNothing,
    );
    expect(
      find.text('Não foi possível concluir o cadastro. Tente novamente.'),
      findsOneWidget,
    );

    // Tentar de novo com sucesso.
    repository.onSignUp = null;
    await _tap(tester, find.text('Cadastrar'));
    expect(find.text('Ir para o login'), findsOneWidget);
  });

  testWidgets(
    'Preenchimento automático: dicas dos campos e salvar ao concluir',
    (tester) async {
      await _pump(tester);
      await _chooseType(tester, 'Cuidador Familiar');

      expect(find.byType(AutofillGroup), findsOneWidget);
      expect(_textField(tester, 'Nome completo').autofillHints, [
        AutofillHints.name,
      ]);
      expect(_textField(tester, 'E-mail').autofillHints, [AutofillHints.email]);
      expect(_textField(tester, 'Telefone').autofillHints, [
        AutofillHints.telephoneNumberNational,
      ]);
      expect(_textField(tester, 'Senha').autofillHints, [
        AutofillHints.newPassword,
      ]);
      expect(_textField(tester, 'Confirmar senha').autofillHints, [
        AutofillHints.newPassword,
      ]);

      tester.testTextInput.log.clear();
      await _submitValid(tester);
      expect(
        tester.testTextInput.log.where(
          (call) =>
              call.method == 'TextInput.finishAutofillContext' &&
              call.arguments == true,
        ),
        hasLength(1),
      );
    },
  );

  testWidgets('Enviar pelo teclado só cadastra com o aceite marcado', (
    tester,
  ) async {
    final repository = await _pump(tester);
    await _chooseType(tester, 'Cuidador Familiar');
    await _fill(tester);

    await tester.showKeyboard(_field('Confirmar senha'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repository.requests, isEmpty);

    await _acceptTerms(tester);
    await tester.showKeyboard(_field('Confirmar senha'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(repository.requests, hasLength(1));
    expect(find.text('Ir para o login'), findsOneWidget);
  });

  for (final (name, theme) in [
    ('claro', AppTheme.light),
    ('escuro', AppTheme.dark),
  ]) {
    testWidgets('Tema $name em tela pequena, com teclado: sem overflow', (
      tester,
    ) async {
      final repository = await _pump(
        tester,
        size: const Size(320, 568),
        theme: theme,
      );
      final colors = theme.extension<CareSyncColors>()!;

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        colors.background,
      );
      final card = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(SignupTypeCard).first,
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect((card.decoration! as BoxDecoration).color, colors.card);

      await _chooseType(tester, 'Cuidador Profissional');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      await _acceptTerms(tester);
      await _tap(tester, find.text('Cadastrar'));
      expect(find.text('Informe seu nome completo.'), findsOneWidget);
      await _tap(tester, find.bySemanticsLabel('Mostrar senha'));

      repository.onSignUp = () async =>
          throw const SignupFailure(SignupFailureReason.network);
      await _fill(tester);
      await _tap(tester, find.text('Cadastrar'));
      expect(find.textContaining('Sem conexão'), findsOneWidget);
      await _tapTermsPart(tester, 'termos de uso');
      await tester.tap(find.bySemanticsLabel('Fechar'));
      await tester.pumpAndSettle();

      tester.view.resetViewInsets();
      repository.onSignUp = null;
      await _tap(tester, find.text('Cadastrar'));
      expect(find.text('Ir para o login'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  test('validateSignup', () {
    SignupErrors validate({
      String name = 'Ana',
      String email = 'a@b.com',
      String phone = '(11) 98888-7777',
      String password = 'segredo12',
      String confirm = 'segredo12',
    }) => validateSignup(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirm,
      isValidEmail: isValidHtmlEmail,
    );

    expect(validate().isValid, isTrue);
    expect(validate(name: ' ').name, isNotNull);
    expect(validate(email: '').email, 'Informe seu e-mail.');
    expect(validate(email: 'ana').email, 'Informe um e-mail válido.');
    expect(validate(phone: '').phone, 'Informe seu telefone.');
    expect(validate(phone: '988887777').phone, 'Informe o telefone com DDD.');
    expect(validate(phone: '1133334444').phone, isNull);
    expect(validate(password: '', confirm: '').password, isNotNull);
    expect(
      validate(password: '1234567', confirm: '1234567').password,
      'A senha deve ter pelo menos 8 caracteres.',
    );
    expect(validate(password: '12345678', confirm: '12345678').isValid, isTrue);
    expect(validate(confirm: '').confirmPassword, 'Confirme sua senha.');
    expect(validate(confirm: 'y').confirmPassword, 'As senhas não coincidem.');
    // Senha não é aparada: espaço faz diferença.
    expect(
      validate(password: 'segredo12 ', confirm: 'segredo12').isValid,
      isFalse,
    );
  });
}
