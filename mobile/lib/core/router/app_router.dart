import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/alimentacao/presentation/alimentacao_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/configuracoes/presentation/configuracoes_screen.dart';
import '../../features/consultas/presentation/consultas_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/indicadores/presentation/indicadores_screen.dart';
import '../../features/medicacoes/presentation/medicacoes_screen.dart';
import '../../features/perfil/presentation/perfil_screen.dart';
import '../../features/relatorios/presentation/relatorios_screen.dart';
import '../widgets/bottom_nav_shell.dart';
import 'route_paths.dart';

/// Configuração central de navegação do CareSync via `go_router`
/// (PROJECT_SPEC.md, seção 3 — mapa de navegação, e seção 10).
///
/// - Telas iniciais/autenticação (`splash`, `onboarding`, `login`, `signup`)
///   ficam fora da casca de navegação.
/// - As 4 abas do BottomNav (`dashboard`, `consultas`, `indicadores`,
///   `relatorios`) usam `StatefulShellRoute.indexedStack`, preservando o
///   estado de cada aba.
/// - As telas secundárias (`medicacoes`, `alimentacao`, `perfil`,
///   `configuracoes`, `chat`) são navegadas como rotas "push", fora do
///   shell — incluindo `configuracoes` e `chat`, que no protótipo original
///   não tinham nenhum ponto de entrada na UI (problema #1 da seção 9 do
///   PROJECT_SPEC.md); aqui já ficam preparadas com rota própria para que,
///   ao implementar as telas, seja simples dar a elas um ponto de entrada
///   real.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BottomNavShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.consultas,
                builder: (context, state) => const ConsultasScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.indicadores,
                builder: (context, state) => const IndicadoresScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.relatorios,
                builder: (context, state) => const RelatoriosScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.medicacoes,
        builder: (context, state) => const MedicacoesScreen(),
      ),
      GoRoute(
        path: RoutePaths.alimentacao,
        builder: (context, state) => const AlimentacaoScreen(),
      ),
      GoRoute(
        path: RoutePaths.perfil,
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: RoutePaths.configuracoes,
        builder: (context, state) => const ConfiguracoesScreen(),
      ),
      GoRoute(
        path: RoutePaths.chat,
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
});
