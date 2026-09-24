import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monta estilos Inter com as métricas exatas do protótipo (tamanho e
/// altura de linha em px, sem espaçamento entre letras e com a entrelinha
/// distribuída igualmente acima e abaixo do texto, como no CSS).
///
/// Referência das classes do Tailwind v4 usadas no protótipo:
/// `text-xs` 12/16, `text-sm` 14/20, base 16/24, `text-lg` 18/28,
/// `text-xl` 20/28, `text-2xl` 24/32, `text-3xl` 30/36.
abstract final class AppTypography {
  static TextStyle inter({
    required double size,
    required double lineHeight,
    FontWeight weight = FontWeight.w400,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: 0,
      color: color,
      decoration: decoration,
      decorationColor: color,
    ).copyWith(leadingDistribution: TextLeadingDistribution.even);
  }
}
