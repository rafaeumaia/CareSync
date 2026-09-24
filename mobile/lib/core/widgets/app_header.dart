import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'lucide_icon.dart';

/// Header padrão das abas principais (PROJECT_SPEC.md, seção 4), fiel a
/// `Header.tsx` do protótipo:
/// - fundo `card` com a sombra padrão, padding de 16px (`px-4 py-4`);
/// - saudação "Olá, {nome} 👋" em 18px (`text-lg`) com peso 500;
/// - sino de notificações (40x40, ícone de 20px) com um ponto vermelho de
///   8px quando há notificações — decorativo, sem ação no protótipo;
/// - avatar de 48px com borda `primary` de 2px e as iniciais em branco
///   sobre `accent`; tocar no avatar abre o Perfil.
///
/// O header também cobre a área da status bar, para que ela fique sobre o
/// mesmo fundo branco.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.userName,
    required this.onAvatarTap,
    this.notificationCount = 0,
  });

  final String userName;
  final int notificationCount;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final topInset = MediaQuery.paddingOf(context).top;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 16),
          decoration: BoxDecoration(
            color: colors.card,
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Olá, $userName 👋',
                  style: AppTypography.inter(
                    size: 18,
                    lineHeight: 28,
                    weight: FontWeight.w500,
                    color: colors.foreground,
                  ),
                ),
              ),
              _NotificationBell(hasNotifications: notificationCount > 0),
              const SizedBox(width: 12),
              _HeaderAvatar(
                initials: initialsOf(userName),
                userName: userName,
                onTap: onAvatarTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Iniciais do nome: primeira letra do primeiro e do último nome, como em
/// `getInitials` do protótipo.
String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  if (words.isEmpty || words.first.isEmpty) return '';
  if (words.length == 1) return words.first[0].toUpperCase();
  return (words.first[0] + words.last[0]).toUpperCase();
}

class _NotificationBell extends StatefulWidget {
  const _NotificationBell({required this.hasNotifications});

  final bool hasNotifications;

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    // O sino não tem ação no protótipo; só o feedback visual
    // (`hover:bg-secondary`) é reproduzido.
    return Semantics(
      button: true,
      label: 'Notificações',
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _pressed ? colors.secondary : colors.secondary.withValues(alpha: 0),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              LucideIcon('bell', size: 20, color: colors.foreground),
              if (widget.hasNotifications)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    key: const ValueKey('notification-dot'),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.destructive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatefulWidget {
  const _HeaderAvatar({
    required this.initials,
    required this.userName,
    required this.onTap,
  });

  final String initials;
  final String userName;
  final VoidCallback onTap;

  @override
  State<_HeaderAvatar> createState() => _HeaderAvatarState();
}

class _HeaderAvatarState extends State<_HeaderAvatar> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    // `transition-transform active:scale-95`.
    return Semantics(
      button: true,
      label: 'Ir para o perfil',
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.4, 0, 0.2, 1),
          child: Container(
            key: const ValueKey('header-avatar'),
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: Text(
              widget.initials,
              style: AppTypography.inter(
                size: 16,
                lineHeight: 24,
                color: colors.primaryForeground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
