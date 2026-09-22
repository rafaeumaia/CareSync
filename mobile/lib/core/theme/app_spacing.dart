/// Espaçamentos do design system do CareSync (PROJECT_SPEC.md, seção 5.3).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Largura máxima do container central (`app-container`), pensado para
  /// ficar bem também em telas maiores/tablet.
  static const double maxContentWidth = 900;

  /// Padding horizontal de conteúdo em telas de largura mobile (<768px).
  static const double screenPaddingMobile = 16;

  /// Padding horizontal de conteúdo em telas ≥768px (breakpoint tablet).
  static const double screenPaddingTablet = 24;

  /// Breakpoint usado para alternar entre os espaçamentos mobile/tablet.
  static const double tabletBreakpoint = 768;

  /// Espaçamento entre cards/seções em telas mobile.
  static const double sectionGapMobile = 12;

  /// Espaçamento entre cards/seções em telas ≥768px.
  static const double sectionGapTablet = 16;

  /// Padding inferior de tela para não sobrepor o BottomNav.
  static const double bottomNavClearance = 80;
}
