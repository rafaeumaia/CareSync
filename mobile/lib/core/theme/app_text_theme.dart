import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tipografia do design system do CareSync (PROJECT_SPEC.md, seção 5.2):
/// fonte Inter, tamanho base 16px, pesos 400/500/600/700.
abstract final class AppTextTheme {
  static const _weightNormal = FontWeight.w400;
  static const _weightMedium = FontWeight.w500;
  static const _weightSemibold = FontWeight.w600;
  static const _weightBold = FontWeight.w700;

  /// Monta o [TextTheme] Inter para a cor de texto principal informada
  /// (`foreground` no tema claro, `foreground` no tema escuro).
  static TextTheme build(Color textColor, Color mutedColor) {
    final base = GoogleFonts.interTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );
    return base
        .copyWith(
          // Título de tela (~24px/semibold).
          headlineSmall: base.headlineSmall?.copyWith(
            fontSize: 24,
            fontWeight: _weightSemibold,
            color: textColor,
          ),
          // Título de card/seção (~18-20px/medium).
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: _weightMedium,
            color: textColor,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: _weightMedium,
            color: textColor,
          ),
          // Corpo (~16px/normal).
          bodyLarge: base.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: _weightNormal,
            color: textColor,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: _weightNormal,
            color: textColor,
          ),
          // Textos auxiliares (datas, legendas) ~14px, mutedForeground.
          bodySmall: base.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: _weightNormal,
            color: mutedColor,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: _weightMedium,
            color: textColor,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontSize: 14,
            fontWeight: _weightMedium,
            color: textColor,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontSize: 14,
            fontWeight: _weightNormal,
            color: mutedColor,
          ),
        );
  }

  static const List<FontWeight> availableWeights = [
    _weightNormal,
    _weightMedium,
    _weightSemibold,
    _weightBold,
  ];
}
