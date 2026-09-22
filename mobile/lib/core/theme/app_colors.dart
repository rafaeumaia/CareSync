import 'package:flutter/material.dart';

/// Tokens de cor do design system do CareSync, extraídos de `globals.css`
/// no protótipo Figma Make (ver PROJECT_SPEC.md, seção 5.1).
///
/// Mantidos como constantes estáticas (não como [ThemeExtension]) porque
/// são usados tanto para montar o [ColorScheme] padrão do Material quanto
/// para alimentar [CareSyncColors], a extensão de tema com os tokens
/// semânticos que não têm equivalente direto no Material (ex.: `success`,
/// `warning`, `ring`).
abstract final class AppColorTokens {
  // Claro
  static const lightBackground = Color(0xFFEAF6FF);
  static const lightForeground = Color(0xFF333333);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardForeground = Color(0xFF333333);
  static const lightPrimary = Color(0xFF2F80ED);
  static const lightPrimaryForeground = Color(0xFFFFFFFF);
  static const lightSecondary = Color(0xFFF2F2F2);
  static const lightSecondaryForeground = Color(0xFF333333);
  static const lightMutedForeground = Color(0xFF666666);
  static const lightAccent = Color(0xFF56CCF2);
  static const lightDestructive = Color(0xFFEB5757);
  static const lightSuccess = Color(0xFF27AE60);
  static const lightWarning = Color(0xFFF2994A);
  static const lightBorder = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const lightInputBackground = Color(0xFFF2F2F2);
  static const lightRing = Color(0xFF2F80ED);

  // Escuro
  static const darkBackground = Color(0xFF121212);
  static const darkForeground = Color(0xFFE0E0E0);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkCardForeground = Color(0xFFE0E0E0);
  static const darkPrimary = Color(0xFF4A90E2);
  static const darkPrimaryForeground = Color(0xFFFFFFFF);
  static const darkSecondary = Color(0xFF2A2A2A);
  static const darkSecondaryForeground = Color(0xFFE0E0E0);
  static const darkMutedForeground = Color(0xFFA0A0A0);
  static const darkAccent = Color(0xFF56CCF2);
  static const darkDestructive = Color(0xFFEB5757);
  static const darkSuccess = Color(0xFF27AE60);
  static const darkWarning = Color(0xFFF2994A);
  static const darkBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  // Não documentado no protótipo original (ver PROJECT_SPEC.md nota da
  // seção 5.1); usa o mesmo tom do `secondary`/`muted` escuro, coerente
  // com o restante da paleta escura.
  static const darkInputBackground = darkSecondary;
  static const darkRing = Color(0xFF4A90E2);
}

/// Extensão de tema com os tokens semânticos do CareSync que não têm um
/// slot correspondente no [ColorScheme] padrão do Material (ex.: `success`,
/// `warning`, `ring`, `inputBackground`).
///
/// Uso: `Theme.of(context).extension<CareSyncColors>()!.success`.
@immutable
class CareSyncColors extends ThemeExtension<CareSyncColors> {
  const CareSyncColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.mutedForeground,
    required this.accent,
    required this.destructive,
    required this.success,
    required this.warning,
    required this.border,
    required this.inputBackground,
    required this.ring,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color mutedForeground;
  final Color accent;
  final Color destructive;
  final Color success;
  final Color warning;
  final Color border;
  final Color inputBackground;
  final Color ring;

  static const light = CareSyncColors(
    background: AppColorTokens.lightBackground,
    foreground: AppColorTokens.lightForeground,
    card: AppColorTokens.lightCard,
    cardForeground: AppColorTokens.lightCardForeground,
    primary: AppColorTokens.lightPrimary,
    primaryForeground: AppColorTokens.lightPrimaryForeground,
    secondary: AppColorTokens.lightSecondary,
    secondaryForeground: AppColorTokens.lightSecondaryForeground,
    mutedForeground: AppColorTokens.lightMutedForeground,
    accent: AppColorTokens.lightAccent,
    destructive: AppColorTokens.lightDestructive,
    success: AppColorTokens.lightSuccess,
    warning: AppColorTokens.lightWarning,
    border: AppColorTokens.lightBorder,
    inputBackground: AppColorTokens.lightInputBackground,
    ring: AppColorTokens.lightRing,
  );

  static const dark = CareSyncColors(
    background: AppColorTokens.darkBackground,
    foreground: AppColorTokens.darkForeground,
    card: AppColorTokens.darkCard,
    cardForeground: AppColorTokens.darkCardForeground,
    primary: AppColorTokens.darkPrimary,
    primaryForeground: AppColorTokens.darkPrimaryForeground,
    secondary: AppColorTokens.darkSecondary,
    secondaryForeground: AppColorTokens.darkSecondaryForeground,
    mutedForeground: AppColorTokens.darkMutedForeground,
    accent: AppColorTokens.darkAccent,
    destructive: AppColorTokens.darkDestructive,
    success: AppColorTokens.darkSuccess,
    warning: AppColorTokens.darkWarning,
    border: AppColorTokens.darkBorder,
    inputBackground: AppColorTokens.darkInputBackground,
    ring: AppColorTokens.darkRing,
  );

  @override
  CareSyncColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? mutedForeground,
    Color? accent,
    Color? destructive,
    Color? success,
    Color? warning,
    Color? border,
    Color? inputBackground,
    Color? ring,
  }) {
    return CareSyncColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      destructive: destructive ?? this.destructive,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      border: border ?? this.border,
      inputBackground: inputBackground ?? this.inputBackground,
      ring: ring ?? this.ring,
    );
  }

  @override
  CareSyncColors lerp(ThemeExtension<CareSyncColors>? other, double t) {
    if (other is! CareSyncColors) return this;
    return CareSyncColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground:
          Color.lerp(primaryForeground, other.primaryForeground, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground:
          Color.lerp(secondaryForeground, other.secondaryForeground, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      border: Color.lerp(border, other.border, t)!,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
    );
  }
}

/// Acesso rápido aos tokens do tema atual: `context.careSyncColors.success`.
extension CareSyncColorsContext on BuildContext {
  CareSyncColors get careSyncColors =>
      Theme.of(this).extension<CareSyncColors>()!;
}
