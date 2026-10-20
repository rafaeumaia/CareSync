import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_action_button.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/medicacao.dart';

/// Card de uma medicação (`MedicacoesScreen.tsx`), com padding de 16px:
/// - à esquerda, a pílula de 28px num quadrado de 56px `rounded-xl` — verde
///   (`success`) se tomada, azul (`primary`) se não — a 16px (`gap-4`) do
///   conteúdo;
/// - nome (18px/600) e dosagem (14px, `muted-foreground`), com o badge
///   "Tomado" à direita quando tomada; 8px abaixo (`mb-2`), o relógio com o
///   horário e, 4px abaixo (`space-y-1`), a frequência recuada 24px;
/// - 12px abaixo (`mb-3`), o botão verde "Marcar como tomado" (`size="sm"`,
///   32px), quando não tomada.
///
/// Além do protótipo (melhorias aprovadas): o botão de excluir (lixeira
/// `destructive`, como em Consultas) no canto superior direito e, quando
/// tomada, o botão `outline` "Desmarcar como tomado" no lugar do verde.
class MedicacaoCard extends StatelessWidget {
  const MedicacaoCard({
    super.key,
    required this.medicacao,
    required this.onMarkTaken,
    required this.onUnmarkTaken,
    required this.onDelete,
  });

  final Medicacao medicacao;
  final VoidCallback onMarkTaken;
  final VoidCallback onUnmarkTaken;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final taken = medicacao.taken;
    final tint = taken ? colors.success : colors.primary;
    final small = AppTypography.inter(size: 14, lineHeight: 20);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: LucideIcon('pill', size: 28, color: tint),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            medicacao.name,
                            style: AppTypography.inter(
                              size: 18,
                              lineHeight: 28,
                              weight: FontWeight.w600,
                              color: colors.cardForeground,
                            ),
                          ),
                          Text(
                            medicacao.dosage,
                            style: small.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (taken) ...[
                      const SizedBox(width: 8),
                      AppBadge(
                        label: 'Tomado',
                        icon: 'check',
                        backgroundColor: colors.success,
                        foregroundColor: Colors.white,
                      ),
                    ],
                    const SizedBox(width: 8),
                    AppIconActionButton(
                      key: ValueKey('excluir-medicacao-${medicacao.id}'),
                      icon: 'trash-2',
                      color: colors.destructive,
                      semanticLabel: 'Excluir ${medicacao.name}',
                      onTap: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    LucideIcon(
                      'clock',
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medicacao.time,
                        style: small.copyWith(color: colors.cardForeground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    medicacao.frequency,
                    style: small.copyWith(color: colors.mutedForeground),
                  ),
                ),
                const SizedBox(height: 12),
                if (!taken)
                  AppButton(
                    key: ValueKey('marcar-tomado-${medicacao.id}'),
                    label: 'Marcar como tomado',
                    icon: 'check',
                    // `gap-1.5` do botão `sm` + `mr-2` do ícone.
                    iconSpacing: 14,
                    height: 32,
                    color: colors.success,
                    onPressed: onMarkTaken,
                  )
                else
                  AppButton(
                    key: ValueKey('desmarcar-tomado-${medicacao.id}'),
                    label: 'Desmarcar como tomado',
                    icon: 'undo-2',
                    iconSpacing: 14,
                    height: 32,
                    variant: AppButtonVariant.outline,
                    onPressed: onUnmarkTaken,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card informativo "Lembre-se": fundo `accent` a 10%, sem borda visível
/// (o `border-0` do Card prevalece), 💡 de 24px a 12px (`gap-3`) do título
/// (16px/500) e, 4px abaixo (`mb-1`), do texto (14px, `muted-foreground`).
///
/// O texto promete notificações automáticas, mas, como no protótipo,
/// nenhuma é agendada nesta etapa.
class LembreteInfoCard extends StatelessWidget {
  const LembreteInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: colors.accent.withValues(alpha: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: AppTypography.inter(size: 24, lineHeight: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lembre-se',
                  style: AppTypography.inter(
                    size: 16,
                    lineHeight: 24,
                    weight: FontWeight.w500,
                    color: colors.cardForeground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Você receberá notificações automáticas nos horários '
                  'programados para cada medicamento.',
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
    );
  }
}
