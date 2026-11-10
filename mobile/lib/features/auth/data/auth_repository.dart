import '../domain/signup.dart';

/// Contrato de autenticação.
///
/// A implementação definitiva chamará a API Django (CLAUDE.md); até lá,
/// [MockAuthRepository] reproduz o protótipo, que trata qualquer cadastro
/// como sucesso.
abstract interface class AuthRepository {
  /// Cadastra o usuário. Lança [SignupFailure] se a API recusar o cadastro
  /// (ex.: e-mail já usado) ou se não houver conexão.
  Future<void> signUp(SignupRequest request);
}

/// Não cadastra nada nem guarda dados (nem a senha): só conclui com
/// sucesso, como o `handleSubmit` do protótipo.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<void> signUp(SignupRequest request) async {}
}
