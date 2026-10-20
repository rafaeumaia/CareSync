import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'lucide_icon.dart';

/// Variantes do botão padrão do CareSync, equivalentes às variantes
/// `default`, `ghost` e `outline` do componente `Button` do protótipo Figma
/// Make.
enum AppButtonVariant { primary, ghost, outline }

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
/// - [AppButtonVariant.outline]: fundo `background` com borda de 1px
///   `border` e texto `foreground` (no escuro, fundo `input/30` e borda
///   `input`); pressionado, como o ghost.
///
/// [color] substitui o fundo do [AppButtonVariant.primary] (ex.:
/// `bg-[#27AE60] hover:bg-[#27AE60]/90`); [icon] é um ícone lucide de 16px
/// antes do texto, a [iconSpacing] dele. Com [expand] `false`, o botão tem
/// a largura do conteúdo (padding `px-4`).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.height = 48,
    this.color,
    this.icon,
    this.iconSpacing = 8,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double height;
  final Color? color;
  final String? icon;
  final double iconSpacing;
  final bool expand;

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
    final primaryBackground = color ?? colors.primary;
    final idleBackground = isPrimary ? primaryBackground : Colors.transparent;
    final pressedBackground = isPrimary
        ? primaryBackground.withValues(alpha: 0.9)
        : colors.accent;

    final isOutline = variant == AppButtonVariant.outline;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // `--input` escuro: rgba(255, 255, 255, 0.1).
    const darkInput = Color(0x1AFFFFFF);
    final outlineBackground =
        isDark ? Colors.white.withValues(alpha: 0.03) : colors.background;
    final outlineBorder = isDark ? darkInput : colors.border;

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
        width: expand ? double.infinity : null,
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
                side: isOutline
                    ? BorderSide(color: outlineBorder)
                    : BorderSide.none,
              ),
            ),
            textStyle: WidgetStatePropertyAll(textStyle),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => isActive(states)
                  ? pressedBackground
                  : isOutline
                      ? outlineBackground
                      : idleBackground,
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
          child: icon == null
              ? Text(label)
              : Builder(
                  // O ícone herda a cor do texto do botão (`currentColor`).
                  builder: (context) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LucideIcon(
                        icon!,
                        size: 16,
                        color: DefaultTextStyle.of(context).style.color,
                      ),
                      SizedBox(width: iconSpacing),
                      Flexible(child: Text(label)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
