import 'package:flutter/material.dart';

/// Sombras do design system do CareSync (PROJECT_SPEC.md, seção 5.5).
abstract final class AppShadows {
  /// Sombra padrão, usada em cards, Header e BottomNav.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D000000), // rgba(0,0,0,0.05)
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  /// Mesma sombra padrão, invertida, para o BottomNav (fixado embaixo).
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, -2),
      blurRadius: 8,
    ),
  ];

  /// Sombra mais acentuada do FAB (`shadow-lg`), para reforçar elevação.
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: Color(0x26000000), // rgba(0,0,0,0.15)
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
