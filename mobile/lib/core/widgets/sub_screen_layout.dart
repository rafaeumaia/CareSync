import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router/route_paths.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_fab.dart';
import 'bottom_nav_shell.dart';

/// Estrutura das telas secundárias com header colorido próprio
/// (`medicacoes`, `alimentacao`...): o [header] rola junto com o conteúdo
/// (no protótipo ele não é `sticky`), tudo limitado ao `app-container`
/// (900px), com o [fab] opcional e o BottomNav fixos embaixo.
///
/// O BottomNav aparece sem aba ativa (no protótipo, `currentScreen` não é
/// nenhuma das 4 abas) e leva às abas principais.
///
/// A faixa da barra de status é pintada com [statusBarColor] (a cor do
/// header), para que os ícones claros do sistema continuem legíveis quando
/// o conteúdo rola por baixo dela.
class SubScreenLayout extends StatelessWidget {
  const SubScreenLayout({
    super.key,
    required this.header,
    required this.body,
    required this.statusBarColor,
    this.fab,
  });

  static const _tabPaths = [
    RoutePaths.dashboard,
    RoutePaths.consultas,
    RoutePaths.indicadores,
    RoutePaths.relatorios,
  ];

  final Widget header;

  /// Conteúdo abaixo do header, sem padding próprio de tela.
  final Widget body;
  final Color statusBarColor;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: AppBottomNav(
          currentIndex: -1,
          onTap: (index) => context.go(_tabPaths[index]),
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: topInset),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [header, body],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topInset,
              child: ColoredBox(color: statusBarColor),
            ),
            if (fab != null)
              Positioned(
                right: AppFab.right,
                bottom: AppFab.bottom,
                child: fab!,
              ),
          ],
        ),
      ),
    );
  }
}
