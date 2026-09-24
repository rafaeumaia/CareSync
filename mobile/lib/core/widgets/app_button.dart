import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Variantes do botão padrão do CareSync, equivalentes às variantes
/// `default` e `ghost` do componente `Button` do protótipo Figma Make.
enum AppButtonVariant { primary, ghost }

/// Botão de largura total do design system do CareSync.
///
/// Reproduz o `Button` do protótipo (`ui/button.tsx`) com a altura `h-12`
/// usada nas telas de fluxo inicial/autenticação: texto 14px (`text-sm`)
/// com peso 500 (`font-medium`), cantos `rounded-md` e opacidade 50% quando
/// desabilitado.
///
/// - [AppButtonVariant.primary]: fundo `primary`, texto `primary-foreground`;
///   pressionado, `primary` a 90% (`hover:bg-primary/90`).
/// - [AppButtonVariant.ghost]: sem fundo, texto `foreground`; pressionado,
///   fundo `accent` com texto branco (`hover:bg-accent
///   hover:text-accent-foreground`).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isPrimary = variant == AppButtonVariant.primary;

    // Primary pressionado mantém `primary-foreground`; ghost pressionado usa
    // `accent-foreground`, que é #FFFFFF nos dois temas — mesmo valor de
    // `primary-foreground`.
    final pressedForeground = colors.primaryForeground;
    final idleForeground =
        isPrimary ? colors.primaryForeground : colors.foreground;
    final idleBackground = isPrimary ? colors.primary : Colors.transparent;
    final pressedBackground = isPrimary
        ? colors.primary.withValues(alpha: 0.9)
        : colors.accent;

    bool isActive(Set<WidgetState> states) =>
        states.contains(WidgetState.pressed) ||
        states.contains(WidgetState.hovered);

    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0,
          leadingDistribution: TextLeadingDistribution.even,
        );

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            textStyle: WidgetStatePropertyAll(textStyle),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => isActive(states) ? pressedBackground : idleBackground,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => isActive(states) ? pressedForeground : idleForeground,
            ),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            splashFactory: NoSplash.splashFactory,
            elevation: const WidgetStatePropertyAll(0),
            minimumSize: const WidgetStatePropertyAll(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
