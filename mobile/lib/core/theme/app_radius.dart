/// Raios de borda do design system do CareSync (PROJECT_SPEC.md, seção 5.4).
///
/// Valores conferidos no `globals.css` do protótipo: `--radius: 0.75rem`,
/// com `--radius-md: calc(var(--radius) - 2px)`, `--radius-lg:
/// var(--radius)` e `--radius-xl: calc(var(--radius) + 4px)`.
abstract final class AppRadius {
  /// Cards (`rounded-xl` = 16px).
  static const double card = 16;

  /// Itens internos de cards, como as linhas de tarefa (`rounded-lg`).
  static const double item = 12;

  /// Botões, campos e badges (`rounded-md`), ou seja, 10px.
  static const double button = 10;

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
