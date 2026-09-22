/// Caminhos de rota das 13 telas do CareSync (PROJECT_SPEC.md, seção 2),
/// usados tanto pelo `GoRouter` (`core/router/app_router.dart`) quanto por
/// qualquer navegação programática (`context.go(RoutePaths.dashboard)`).
abstract final class RoutePaths {
  // Inicial / autenticação
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';

  // Abas do BottomNav
  static const dashboard = '/dashboard';
  static const consultas = '/consultas';
  static const indicadores = '/indicadores';
  static const relatorios = '/relatorios';

  // Telas secundárias (navegadas como "sub-telas", com voltar para dashboard)
  static const medicacoes = '/medicacoes';
  static const alimentacao = '/alimentacao';
  static const perfil = '/perfil';
  static const configuracoes = '/configuracoes';
  static const chat = '/chat';
}
