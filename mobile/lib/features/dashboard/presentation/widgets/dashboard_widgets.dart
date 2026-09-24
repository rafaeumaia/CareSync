import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/tinted_icon_circle.dart';
import '../../domain/dashboard_summary.dart';

/// Card de acesso rápido ("Próxima em" / "Medicações"): card clicável com
/// padding de 16px, círculo de ícone de 48px e, ao lado (12px), um rótulo
/// de 14px em `muted-foreground` sobre um valor de 16px com peso 600.
class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppCard(
      onTap: onTap,
      semanticLabel: '$label $value',
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          TintedIconCircle(icon: icon, color: color),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.inter(
                    size: 14,
                    lineHeight: 20,
                    color: colors.mutedForeground,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.inter(
                    size: 16,
                    lineHeight: 24,
                    weight: FontWeight.w600,
                    color: colors.cardForeground,
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

/// Card "Tarefas do Dia": cabeçalho com relógio `primary` de 20px e título
/// de 16px (`leading-none`), 24px de padding e 24px até a lista, com 12px
/// entre as tarefas.
class TasksOfTheDayCard extends StatelessWidget {
  const TasksOfTheDayCard({super.key, required this.tasks});

  final List<DashboardTask> tasks;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              LucideIcon('clock', size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tarefas do Dia',
                  style: AppTypography.inter(
                    size: 16,
                    lineHeight: 16,
                    color: colors.cardForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            TaskTile(task: tasks[i]),
          ],
        ],
      ),
    );
  }
}

/// Linha de tarefa: fundo `secondary`, cantos `rounded-lg`, padding de
/// 12px, círculo de ícone de 40px (ícone de 20px) na cor do tipo, título de
/// 16px/500 (riscado e em `muted-foreground` quando concluída), horário de
/// 14px e, se concluída, o badge "✓" verde.
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task});

  final DashboardTask task;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final (icon, color) = switch (task.type) {
      DashboardTaskType.medication => ('pill', colors.success),
      DashboardTaskType.appointment => ('stethoscope', colors.primary),
      DashboardTaskType.health => ('heart_outline', colors.destructive),
    };
    final titleColor =
        task.done ? colors.mutedForeground : colors.cardForeground;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.item),
      ),
      child: Row(
        children: [
          TintedIconCircle(icon: icon, color: color, size: 40, iconSize: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title,
                  style: AppTypography.inter(
                    size: 16,
                    lineHeight: 24,
                    weight: FontWeight.w500,
                    color: titleColor,
                    decoration:
                        task.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  task.timeLabel,
                  style: AppTypography.inter(
                    size: 14,
                    lineHeight: 20,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          if (task.done) ...[
            const SizedBox(width: 12),
            AppBadge(
              key: ValueKey('task-done-${task.id}'),
              label: '✓',
              backgroundColor: colors.success,
              foregroundColor: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

/// Botão de ação rápida (Indicadores / Alimentação / Relatórios): card
/// clicável com padding de 16px, círculo de ícone de 48px e rótulo de 12px
/// centralizado, 8px abaixo.
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      semanticLabel: label,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TintedIconCircle(icon: icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 12,
              lineHeight: 16,
              color: context.careSyncColors.cardForeground,
            ),
          ),
        ],
      ),
    );
  }
}
