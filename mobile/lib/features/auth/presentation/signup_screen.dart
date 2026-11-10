import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/phone_input_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_text_link.dart';
import '../../../core/widgets/lucide_icon.dart';
import '../domain/documento_legal.dart';
import '../domain/signup.dart';
import '../state/auth_providers.dart';
import 'login_screen.dart' show isValidHtmlEmail;
import 'widgets/auth_scroll_layout.dart';
import 'widgets/legal_document_dialog.dart';
import 'widgets/onboarding_page_indicator.dart';
import 'widgets/signup_type_card.dart';

enum _SignupStep { type, form, success }

/// Cadastro do CareSync (PROJECT_SPEC.md, seção 2 — "Cadastro"), fiel a
/// `SignupScreen.tsx` do protótipo Figma Make, com as mesmas 3 etapas:
/// 1. **Tipo**: tocar num dos 3 perfis avança para o formulário; "Fazer
///    login" volta ao Login.
/// 2. **Formulário**: nome, e-mail, telefone, senha, confirmação e aceite
///    dos termos; "Cadastrar" só habilita com o aceite marcado. "← Voltar"
///    retorna à etapa 1 mantendo tudo o que foi preenchido (no protótipo o
///    `formData` fica na tela), inclusive ao escolher outro perfil.
/// 3. **Sucesso**: diálogo que não fecha tocando fora; "Ir para o login"
///    leva ao Login.
///
/// Validação: o protótipo só tem a do navegador (campos `required` e e-mail
/// `type="email"`), que bloqueia o envio e foca o primeiro campo inválido;
/// aqui, além disso, a confirmação precisa ser igual à senha, e os erros
/// aparecem abaixo de cada campo (e se atualizam enquanto se digita).
///
/// Melhorias aprovadas além do protótipo:
/// - indicador "Passo 1 de 2" / "Passo 2 de 2" abaixo do subtítulo;
/// - mostrar/ocultar cada senha (ícone de olho no campo);
/// - senha com pelo menos [minPasswordLength] caracteres;
/// - telefone com máscara e DDD obrigatório (10 ou 11 dígitos);
/// - "termos de uso" e "política de privacidade" abrem o texto de cada um;
/// - "Cadastrar" mostra carregamento durante o envio; e-mail já cadastrado
///   aparece no campo e outras falhas (ex.: sem conexão) acima do botão;
/// - preenchimento automático do sistema (nome, e-mail, telefone e nova
///   senha), oferecendo salvar a senha no gerenciador do aparelho ao
///   concluir — o app não guarda nada.
///
/// Nada é cadastrado de verdade nem guardado no aparelho: o
/// [authRepositoryProvider] é um mock até a API Django existir.
///
/// Correções de inconsistências do protótipo (CLAUDE.md): `#EAF6FF`,
/// `#2F80ED`, `#27AE60` e `bg-white` viram os tokens `background`,
/// `primary`, `success` e `card` (respeitando o dark mode); o X do diálogo
/// de sucesso, sem efeito no protótipo, leva ao Login como o botão; o
/// voltar do sistema faz o mesmo que "← Voltar" no formulário e volta ao
/// Login na etapa 1.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  var _step = _SignupStep.type;
  TipoUsuario? _tipo;
  var _acceptTerms = false;
  var _submitting = false;
  var _showPassword = false;
  var _showConfirmPassword = false;

  /// Depois da primeira tentativa de envio, os erros acompanham a digitação.
  var _submitted = false;
  var _errors = const SignupErrors();

  /// E-mail recusado pela API (já cadastrado): vale até o e-mail mudar.
  String? _emailTakenError;
  String? _emailTakenFor;

  /// Falha do envio que não é de um campo (ex.: sem conexão).
  String? _submitError;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  late final _termsLink = TapGestureRecognizer()
    ..onTap = () => _openDocument(DocumentoLegal.termosDeUso);
  late final _privacyLink = TapGestureRecognizer()
    ..onTap = () => _openDocument(DocumentoLegal.politicaDePrivacidade);

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _email, _phone, _password, _confirmPassword]) {
      c.addListener(_revalidate);
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirmPassword]) {
      c.dispose();
    }
    for (final f in [
      _nameFocus,
      _emailFocus,
      _phoneFocus,
      _passwordFocus,
      _confirmPasswordFocus,
    ]) {
      f.dispose();
    }
    _termsLink.dispose();
    _privacyLink.dispose();
    super.dispose();
  }

  SignupErrors _validate() => validateSignup(
    name: _name.text,
    email: _email.text,
    phone: _phone.text,
    password: _password.text,
    confirmPassword: _confirmPassword.text,
    isValidEmail: isValidHtmlEmail,
  );

  void _revalidate() {
    if (_submitted) setState(() => _errors = _validate());
  }

  String? get _emailError =>
      _errors.email ??
      (_email.text.trim() == _emailTakenFor ? _emailTakenError : null);

  void _selectType(TipoUsuario tipo) => setState(() {
    _tipo = tipo;
    _step = _SignupStep.form;
  });

  void _backToType() {
    if (_submitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _step = _SignupStep.type);
  }

  void _goToLogin() => context.go(RoutePaths.login);

  void _openDocument(DocumentoLegal documento) {
    FocusManager.instance.primaryFocus?.unfocus();
    showLegalDocumentDialog(
      context: context,
      documento: documento,
      repository: ref.read(legalDocumentsRepositoryProvider),
    );
  }

  Future<void> _submit() async {
    if (!_acceptTerms || _submitting) return;
    final errors = _validate();
    setState(() {
      _submitted = true;
      _errors = errors;
      _submitError = null;
    });
    if (!errors.isValid) {
      _focusFirstInvalid(errors);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submitting = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            SignupRequest(
              tipo: _tipo!,
              name: _name.text.trim(),
              email: _email.text.trim(),
              phone: phoneDigits(_phone.text),
              password: _password.text,
            ),
          );
    } on SignupFailure catch (failure) {
      _showFailure(failure);
      return;
    } on Exception {
      _showFailure(const SignupFailure(SignupFailureReason.unknown));
      return;
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
    if (!mounted) return;

    // Oferece salvar a nova senha no gerenciador de senhas do aparelho.
    TextInput.finishAutofillContext();
    setState(() => _step = _SignupStep.success);
    await showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _SignupSuccessContent(
        onGoToLogin: () {
          Navigator.of(dialogContext).pop();
          if (mounted) _goToLogin();
        },
      ),
    );
  }

  void _focusFirstInvalid(SignupErrors errors) {
    // Como o navegador: foca o primeiro campo inválido, na ordem do form.
    final firstInvalid = [
      (errors.name, _nameFocus),
      (errors.email, _emailFocus),
      (errors.phone, _phoneFocus),
      (errors.password, _passwordFocus),
      (errors.confirmPassword, _confirmPasswordFocus),
    ].firstWhere((e) => e.$1 != null).$2;
    firstInvalid.requestFocus();
  }

  void _showFailure(SignupFailure failure) {
    if (!mounted) return;
    setState(() {
      if (failure.reason == SignupFailureReason.emailAlreadyRegistered) {
        _emailTakenError = failure.message;
        _emailTakenFor = _email.text.trim();
      } else {
        _submitError = failure.message;
      }
    });
    if (failure.reason == SignupFailureReason.emailAlreadyRegistered) {
      _emailFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        switch (_step) {
          case _SignupStep.form:
            _backToType();
          case _SignupStep.type:
            _goToLogin();
          case _SignupStep.success:
            break;
        }
      },
      child: switch (_step) {
        // `key` por etapa: cada etapa começa rolada para o topo.
        _SignupStep.type => AuthScrollLayout(
          key: const ValueKey(_SignupStep.type),
          child: _TypeStep(onSelect: _selectType, onLogin: _goToLogin),
        ),
        _SignupStep.form => AuthScrollLayout(
          key: const ValueKey(_SignupStep.form),
          child: _buildForm(context),
        ),
        // No protótipo, a etapa de sucesso renderiza só o diálogo sobre o
        // fundo da tela.
        _SignupStep.success => const AuthScrollLayout(
          key: ValueKey(_SignupStep.success),
          child: SizedBox.shrink(),
        ),
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final colors = context.careSyncColors;
    const gap = SizedBox(height: 16);
    final small = AppTypography.inter(
      size: 14,
      lineHeight: 20,
      color: colors.mutedForeground,
    );
    TextSpan link(TapGestureRecognizer recognizer, String text) => TextSpan(
      text: text,
      style: small.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
        decorationColor: colors.primary,
      ),
      recognizer: recognizer,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SignupHeader(subtitle: 'Preencha seus dados', step: 2),
        // O contexto de preenchimento só é concluído no sucesso; voltar à
        // etapa 1 não oferece salvar a senha.
        AutofillGroup(
          onDisposeAction: AutofillContextAction.cancel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Nome completo',
                placeholder: 'Seu nome',
                controller: _name,
                focusNode: _nameFocus,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                onSubmitted: (_) => _emailFocus.requestFocus(),
                errorText: _errors.name,
              ),
              gap,
              AppTextField(
                label: 'E-mail',
                placeholder: 'seu@email.com',
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _phoneFocus.requestFocus(),
                errorText: _emailError,
              ),
              gap,
              AppTextField(
                label: 'Telefone',
                placeholder: '(00) 00000-0000',
                controller: _phone,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumberNational],
                inputFormatters: const [BrazilianPhoneInputFormatter()],
                onSubmitted: (_) => _passwordFocus.requestFocus(),
                errorText: _errors.phone,
              ),
              gap,
              AppTextField(
                label: 'Senha',
                placeholder: '••••••••',
                controller: _password,
                focusNode: _passwordFocus,
                obscureText: !_showPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
                errorText: _errors.password,
                suffix: _PasswordVisibilityToggle(
                  visible: _showPassword,
                  fieldLabel: 'senha',
                  onToggle: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              gap,
              AppTextField(
                label: 'Confirmar senha',
                placeholder: '••••••••',
                controller: _confirmPassword,
                focusNode: _confirmPasswordFocus,
                obscureText: !_showConfirmPassword,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                // Enter só envia o `<form>` com o botão habilitado.
                onSubmitted: (_) => _submit(),
                errorText: _errors.confirmPassword,
                suffix: _PasswordVisibilityToggle(
                  visible: _showConfirmPassword,
                  fieldLabel: 'confirmação de senha',
                  onToggle: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                ),
              ),
            ],
          ),
        ),
        gap,
        AppCheckbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value),
          label: 'Aceito os termos de uso e política de privacidade',
          labelStyle: small,
          richLabel: TextSpan(
            children: [
              const TextSpan(text: 'Aceito os '),
              link(_termsLink, 'termos de uso'),
              const TextSpan(text: ' e '),
              link(_privacyLink, 'política de privacidade'),
            ],
          ),
        ),
        if (_submitError != null) ...[
          gap,
          _SubmitErrorBanner(message: _submitError!),
          const SizedBox(height: 24),
        ] else
          // `space-y-4` do aceite + `mt-6` do botão (inline, sem colapso).
          const SizedBox(height: 40),
        AppButton(
          label: _submitting ? 'Cadastrando...' : 'Cadastrar',
          loading: _submitting,
          onPressed: _acceptTerms ? _submit : null,
        ),
        // `space-y-4` do botão + `mt-4` do "Voltar" e, pela linha de texto
        // que o contém (Inter 16px / 24px), 2.73px até o link de 14px.
        const SizedBox(height: 32 + 2.73),
        Center(
          child: AppTextLink(
            label: '← Voltar',
            style: small,
            onPressed: _backToType,
          ),
        ),
      ],
    );
  }
}

/// Cabeçalho das etapas 1 e 2: coração lucide preenchido em `primary`
/// (48px) e, 16px abaixo (`mb-4`), "Criar conta" (30px/600) e, 8px abaixo
/// (`mb-2`), o [subtitle] (16px, `muted-foreground`), 32px acima do
/// conteúdo (`mb-8`).
///
/// Entre o subtítulo e o conteúdo (melhoria aprovada), 16px abaixo do
/// subtítulo, o indicador de etapa: as pílulas do Onboarding e, 8px ao
/// lado, "Passo [step] de 2" (14px, `muted-foreground`).
class _SignupHeader extends StatelessWidget {
  const _SignupHeader({required this.subtitle, required this.step});

  static const _steps = 2;

  final String subtitle;
  final int step;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/icons/heart.svg',
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            size: 30,
            lineHeight: 36,
            weight: FontWeight.w600,
            color: colors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            size: 16,
            lineHeight: 24,
            color: colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Passo $step de $_steps',
          excludeSemantics: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OnboardingPageIndicator(count: _steps, currentIndex: step - 1),
              const SizedBox(width: 8),
              Text(
                'Passo $step de $_steps',
                style: AppTypography.inter(
                  size: 14,
                  lineHeight: 20,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Etapa 1: os 3 perfis a 12px um do outro (`space-y-3`) e, 24px abaixo
/// (`mt-6`), "Já tem uma conta? Fazer login".
class _TypeStep extends StatelessWidget {
  const _TypeStep({required this.onSelect, required this.onLogin});

  final ValueChanged<TipoUsuario> onSelect;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final base = AppTypography.inter(size: 16, lineHeight: 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SignupHeader(subtitle: 'Escolha o tipo de perfil', step: 1),
        for (final (i, tipo) in TipoUsuario.values.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          SignupTypeCard(tipo: tipo, onTap: () => onSelect(tipo)),
        ],
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Já tem uma conta? ',
              style: base.copyWith(color: colors.mutedForeground),
            ),
            AppTextLink(
              label: 'Fazer login',
              style: base.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
              onPressed: onLogin,
            ),
          ],
        ),
      ],
    );
  }
}

/// Olho para mostrar/ocultar a senha: `eye` (oculta) ou `eye-off`
/// (visível), 20px em `muted-foreground`, com área de toque de 40px.
class _PasswordVisibilityToggle extends StatelessWidget {
  const _PasswordVisibilityToggle({
    required this.visible,
    required this.fieldLabel,
    required this.onToggle,
  });

  final bool visible;
  final String fieldLabel;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: visible ? 'Ocultar $fieldLabel' : 'Mostrar $fieldLabel',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: SizedBox.square(
          dimension: 40,
          child: Center(
            child: LucideIcon(
              visible ? 'eye-off' : 'eye',
              size: 20,
              color: context.careSyncColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Falha do envio que não pertence a um campo: fundo `destructive` a 10%,
/// cantos `rounded-md`, padding de 12px, ícone de alerta de 16px a 8px do
/// texto (14px, `destructive`). Anunciada por leitores de tela.
class _SubmitErrorBanner extends StatelessWidget {
  const _SubmitErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final destructive = context.careSyncColors.destructive;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: destructive.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: LucideIcon('circle-alert', size: 16, color: destructive),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.inter(
                  size: 14,
                  lineHeight: 20,
                  color: destructive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Conteúdo do diálogo de sucesso (`DialogHeader` centralizado): coração
/// preenchido `success` de 32px num círculo `success` a 10% de 64px; 24px
/// abaixo (`mb-4` + `gap-2`), o título de 24px/600 (`text-2xl
/// leading-none`); 8px abaixo, a descrição (14px, `muted-foreground`); 16px
/// abaixo (`gap-4`), o botão "Ir para o login" (48px).
///
/// O X e o voltar do sistema também levam ao Login (no protótipo, o
/// diálogo é `open={true}` sem `onOpenChange` e o X não faz nada).
class _SignupSuccessContent extends StatelessWidget {
  const _SignupSuccessContent({required this.onGoToLogin});

  final VoidCallback onGoToLogin;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onGoToLogin();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: LucideIcon(
                'heart_outline',
                size: 32,
                color: colors.success,
                fillColor: colors.success,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cadastro realizado com sucesso! 💙',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 24,
              lineHeight: 24,
              weight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bem-vindo ao CareSync. Agora você pode fazer login e começar a '
            'cuidar com organização.',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 14,
              lineHeight: 20,
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Ir para o login', onPressed: onGoToLogin),
        ],
      ),
    );
  }
}
