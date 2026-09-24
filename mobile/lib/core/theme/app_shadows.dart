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

  /// `shadow-lg` do Tailwind v4: `0 10px 15px -3px rgb(0 0 0 / 0.1),
  /// 0 4px 6px -4px rgb(0 0 0 / 0.1)`. Usada no FAB e como realce de cards
  /// clicáveis (`hover:shadow-lg`).
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  /// Sombra do FAB (`shadow-lg`).
  static const List<BoxShadow> fab = lg;
}
