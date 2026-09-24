import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_text_link.dart';
import 'widgets/auth_scroll_layout.dart';

/// Login do CareSync (PROJECT_SPEC.md, seção 2 — "Login").
///
/// Reproduz `LoginScreen.tsx` do protótipo Figma Make, incluindo o
/// comportamento atual (mock): não há autenticação real. O protótipo usa um
/// `<form>` com os campos `required` e o e-mail `type="email"`, então o
/// navegador só deixa enviar com e-mail em formato válido e senha
/// preenchida; qualquer combinação que passe nisso entra no app
/// (`App.tsx` → `dashboard`). Nenhuma credencial é armazenada.
///
/// - "Esqueci minha senha" não tem ação no protótipo (sem `onClick`).
/// - O protótipo não tem ícones nos campos nem botão de mostrar/ocultar
///   senha.
///
/// Correção de inconsistência do protótipo (CLAUDE.md): `#EAF6FF` e
/// `#2F80ED` estavam hardcoded; aqui usam os tokens `background` e
/// `primary` (idênticos no tema claro), respeitando o dark mode.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Equivalente ao envio do `<form>`: o navegador valida os campos na ordem
  /// do DOM e, se algum for inválido, bloqueia o envio e foca esse campo.
  void _handleSubmit() {
    if (!isValidHtmlEmail(_emailController.text)) {
      _emailFocus.requestFocus();
      return;
    }
    if (_passwordController.text.isEmpty) {
      _passwordFocus.requestFocus();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    context.go(RoutePaths.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final textTheme = Theme.of(context).textTheme;

    TextStyle? style(double size, double lineHeight, FontWeight weight,
            Color color) =>
        textTheme.bodyLarge?.copyWith(
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          letterSpacing: 0,
          leadingDistribution: TextLeadingDistribution.even,
          color: color,
        );

    // `text-3xl font-semibold text-foreground` (30px / 36px).
    final titleStyle = style(30, 36, FontWeight.w600, colors.foreground);
    // Texto base herdado do body: 16px / 24px (`line-height: 1.5`).
    final subtitleStyle =
        style(16, 24, FontWeight.w400, colors.mutedForeground);
    // `text-sm` (14px / 20px), peso herdado (400).
    final forgotStyle = style(14, 20, FontWeight.w400, colors.primary);
    final linkStyle = style(16, 24, FontWeight.w500, colors.primary);

    return AuthScrollLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _LoginLogo(),
          const SizedBox(height: 16),
          Text('CareSync', style: titleStyle, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Cuidar com organização é cuidar melhor.',
            style: subtitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: 'E-mail',
            placeholder: 'seu@email.com',
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Senha',
            placeholder: '••••••••',
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
          ),
          // "Esqueci minha senha" e "Entrar" são inline no `<form>`
          // (`space-y-4` + `mt-6`): pela linha de texto que os contém
          // (Inter 16px / 24px), o link fica 2.73px abaixo do início da
          // linha e há 40px entre o link e o botão.
          const SizedBox(height: 16 + 2.73),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppTextLink(
              label: 'Esqueci minha senha',
              style: forgotStyle,
            ),
          ),
          const SizedBox(height: 40),
          AppButton(label: 'Entrar', onPressed: _handleSubmit),
          // `space-y-4` do botão + `mt-4` do rodapé.
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Não tem uma conta? ', style: subtitleStyle),
              AppTextLink(
                label: 'Criar conta',
                style: linkStyle,
                onPressed: () => context.go(RoutePaths.signup),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Coração lucide preenchido em `primary` (64x64) com um ponto branco de
/// 12x12 centralizado (`w-3 h-3 bg-white rounded-full`).
class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    final primary = context.careSyncColors.primary;
    return Center(
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/heart.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Validação de `<input type="email">` segundo a especificação HTML (a
/// mesma aplicada pelo navegador no protótipo). O valor é aparado antes,
/// como o navegador faz com campos de e-mail.
bool isValidHtmlEmail(String value) => _htmlEmailPattern.hasMatch(value.trim());

final _htmlEmailPattern = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}"
  r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
);
