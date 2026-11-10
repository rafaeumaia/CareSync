/// Tipo de perfil escolhido no cadastro (PROJECT_SPEC.md, seção 12 —
/// `User.tipo`), na ordem do protótipo (`SignupScreen.tsx`).
enum TipoUsuario { profissional, familiar, responsavel }

/// Dados enviados no cadastro. A senha só existe em memória durante o envio;
/// nada é armazenado no aparelho.
class SignupRequest {
  const SignupRequest({
    required this.tipo,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  final TipoUsuario tipo;
  final String name;
  final String email;

  /// Só os dígitos (DDD + número), sem a máscara.
  final String phone;
  final String password;
}

/// Motivos de falha do cadastro que a tela trata de forma específica.
enum SignupFailureReason { emailAlreadyRegistered, network, unknown }

/// Falha do cadastro, lançada pelo repositório (ex.: resposta da API
/// Django ou falta de conexão).
class SignupFailure implements Exception {
  const SignupFailure(this.reason);

  final SignupFailureReason reason;

  String get message => switch (reason) {
    SignupFailureReason.emailAlreadyRegistered =>
      'Este e-mail já está cadastrado.',
    SignupFailureReason.network =>
      'Sem conexão com a internet. Verifique e tente novamente.',
    SignupFailureReason.unknown =>
      'Não foi possível concluir o cadastro. Tente novamente.',
  };

  @override
  String toString() => 'SignupFailure($reason)';
}

/// Tamanho mínimo da senha. Deve acompanhar a regra da API Django.
const minPasswordLength = 8;

/// Erros do formulário de cadastro, um por campo (`null` = válido).
class SignupErrors {
  const SignupErrors({
    this.name,
    this.email,
    this.phone,
    this.password,
    this.confirmPassword,
  });

  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final String? confirmPassword;

  bool get isValid =>
      name == null &&
      email == null &&
      phone == null &&
      password == null &&
      confirmPassword == null;
}

/// Só os dígitos de [phone].
String phoneDigits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

/// Valida o formulário de cadastro.
///
/// O protótipo usa um `<form>` com todos os campos `required` e o e-mail
/// `type="email"` (validação do navegador, reproduzida com
/// [isValidEmail]). Além disso (melhorias aprovadas): o telefone precisa
/// ter DDD + número (10 ou 11 dígitos), a senha ao menos
/// [minPasswordLength] caracteres e a confirmação deve ser igual à senha.
SignupErrors validateSignup({
  required String name,
  required String email,
  required String phone,
  required String password,
  required String confirmPassword,
  required bool Function(String) isValidEmail,
}) {
  final digits = phoneDigits(phone);
  return SignupErrors(
    name: name.trim().isEmpty ? 'Informe seu nome completo.' : null,
    email: email.trim().isEmpty
        ? 'Informe seu e-mail.'
        : isValidEmail(email)
        ? null
        : 'Informe um e-mail válido.',
    phone: digits.isEmpty
        ? 'Informe seu telefone.'
        : digits.length == 10 || digits.length == 11
        ? null
        : 'Informe o telefone com DDD.',
    password: password.isEmpty
        ? 'Informe uma senha.'
        : password.length < minPasswordLength
        ? 'A senha deve ter pelo menos $minPasswordLength caracteres.'
        : null,
    confirmPassword: confirmPassword.isEmpty
        ? 'Confirme sua senha.'
        : confirmPassword != password
        ? 'As senhas não coincidem.'
        : null,
  );
}
