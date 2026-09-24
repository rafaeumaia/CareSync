import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Estrutura comum das telas de fluxo inicial/autenticação do protótipo:
/// `min-h-screen bg-background` com o conteúdo centralizado na vertical
/// (`flex-1 ... justify-center px-6 py-12`) e limitado a `max-w-md` (448px).
///
/// Em Flutter, o conteúdo fica dentro de uma [SafeArea] e rola quando não
/// cabe — inclusive com o teclado aberto, já que o [Scaffold] reduz a área
/// disponível (`resizeToAvoidBottomInset`) e o campo focado é trazido para
/// a área visível automaticamente.
class AuthScrollLayout extends StatelessWidget {
  const AuthScrollLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Align(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
