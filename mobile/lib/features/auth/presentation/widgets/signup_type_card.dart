import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/tinted_icon_circle.dart';
import '../../domain/signup.dart';

/// Card de um perfil na etapa 1 do cadastro (`SignupScreen.tsx`): fundo
/// `card`, cantos `rounded-xl`, borda de 2px `border` que fica `primary`
/// enquanto pressionado (`hover:border-[#2F80ED] transition-colors`, 150ms),
/// padding de 24px; ícone `primary` de 24px num círculo `primary` a 10% de
/// 48px, a 16px (`gap-4`) do título (16px/500) e da descrição (14px,
/// `muted-foreground`). Sem sombra.
class SignupTypeCard extends StatefulWidget {
  const SignupTypeCard({super.key, required this.tipo, required this.onTap});

  final TipoUsuario tipo;
  final VoidCallback onTap;

  static ({String icon, String title, String description}) contentFor(
    TipoUsuario tipo,
  ) => switch (tipo) {
    TipoUsuario.profissional => (
      icon: 'user-cog',
      title: 'Cuidador Profissional',
      description: 'Para profissionais de saúde',
    ),
    TipoUsuario.familiar => (
      icon: 'users',
      title: 'Cuidador Familiar',
      description: 'Para familiares e amigos',
    ),
    TipoUsuario.responsavel => (
      icon: 'briefcase',
      title: 'Responsável',
      description: 'Para gerentes e administradores',
    ),
  };

  @override
  State<SignupTypeCard> createState() => _SignupTypeCardState();
}

class _SignupTypeCardState extends State<SignupTypeCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final content = SignupTypeCard.contentFor(widget.tipo);

    return Semantics(
      button: true,
      label: '${content.title}. ${content.description}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.4, 0, 0.2, 1),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: _pressed ? colors.primary : colors.border,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              TintedIconCircle(icon: content.icon, color: colors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      content.title,
                      style: AppTypography.inter(
                        size: 16,
                        lineHeight: 24,
                        weight: FontWeight.w500,
                        color: colors.foreground,
                      ),
                    ),
                    Text(
                      content.description,
                      style: AppTypography.inter(
                        size: 14,
                        lineHeight: 20,
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
