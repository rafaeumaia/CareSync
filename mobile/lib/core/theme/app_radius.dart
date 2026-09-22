/// Raios de borda do design system do CareSync (PROJECT_SPEC.md, seção 5.4).
abstract final class AppRadius {
  /// Raio base do design system (cards, `rounded-xl`).
  static const double card = 12;

  /// Botões (`rounded-md`).
  static const double button = 8;

  /// Avatares, badges de status, FAB (`rounded-full`).
  static const double full = 999;

  /// Cantos inferiores dos headers coloridos de tela (`rounded-b-3xl`).
  static const double headerBottom = 24;

  /// Bolhas de chat (`rounded-2xl`).
  static const double chatBubble = 16;

  /// Canto "puxado" da bolha de chat de quem enviou a mensagem
  /// (`rounded-br-sm` / `rounded-bl-sm`).
  static const double chatBubbleTail = 4;
}
