import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_fab.dart';

/// Estrutura das abas principais com o [header] padrão fixo no topo
/// (`sticky top-0 z-10`), conteúdo rolável limitado ao `app-container`
/// (900px) e, opcionalmente, o botão flutuante [fab] acima do BottomNav.
///
/// O header é pintado por último, para que a sua sombra fique sobre o
/// conteúdo rolado.
class HeaderScreenLayout extends StatelessWidget {
  const HeaderScreenLayout({
    super.key,
    required this.header,
    required this.body,
    this.fab,
  });

  final Widget header;

  /// Conteúdo rolável, sem padding próprio de tela.
  final Widget body;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: ColoredBox(
        color: colors.background,
        child: Stack(
          children: [
            Column(
              verticalDirection: VerticalDirection.up,
              children: [
                Expanded(
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
                          child: body,
                        ),
                      ),
                    ),
                  ),
                ),
                header,
              ],
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
