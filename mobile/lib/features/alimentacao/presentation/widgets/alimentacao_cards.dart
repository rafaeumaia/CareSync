import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_titled_card.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/hidratacao.dart';
import '../../domain/planejamento_semanal.dart';
import '../../domain/recomendacao.dart';
import '../../domain/refeicao.dart';

TextStyle _small(Color color) =>
    AppTypography.inter(size: 14, lineHeight: 20, color: color);

/// Card "Refeições do Dia": as [refeicoes] a 12px uma da outra
/// (`space-y-3`).
class RefeicoesDoDiaCard extends StatelessWidget {
  const RefeicoesDoDiaCard({
    super.key,
    required this.refeicoes,
    required this.onConfirm,
  });

  final List<Refeicao> refeicoes;
  final ValueChanged<Refeicao> onConfirm;

  @override
  Widget build(BuildContext context) {
    return AppTitledCard(
      title: 'Refeições do Dia',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < refeicoes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            RefeicaoItem(
              key: ValueKey('refeicao-${refeicoes[i].id}'),
              refeicao: refeicoes[i],
              onConfirm: () => onConfirm(refeicoes[i]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Uma refeição (`p-4 rounded-xl border-2`):
/// - confirmada: borda `success` e fundo `success` a 5%; ícone branco num
///   círculo `success` de 48px e badge de check à direita do nome;
/// - pendente: borda `border`; ícone `warning` num círculo `warning` a 20%
///   e, 8px abaixo da descrição (`mt-2`), o botão `outline` verde
///   "Confirmar refeição" (`size="sm"`, 32px);
/// - 12px (`gap-3`) entre o ícone e o conteúdo: nome (16px/600), 4px abaixo
///   (`mb-1`) o horário (14px, `muted-foreground`) e, 4px abaixo, a
///   descrição (14px).
class RefeicaoItem extends StatelessWidget {
  const RefeicaoItem({
    super.key,
    required this.refeicao,
    required this.onConfirm,
  });

  final Refeicao refeicao;
  final VoidCallback onConfirm;

  static String iconFor(TipoRefeicao tipo) => switch (tipo) {
    TipoRefeicao.cafeDaManha => 'coffee',
    TipoRefeicao.almoco => 'sun',
    TipoRefeicao.lanche => 'sandwich',
    TipoRefeicao.jantar => 'moon',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final completed = refeicao.completed;

    return AnimatedContainer(
      // `transition-all` (150ms).
      duration: const Duration(milliseconds: 150),
      curve: const Cubic(0.4, 0, 0.2, 1),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? colors.success.withValues(alpha: 0.05)
            : colors.success.withValues(alpha: 0),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: completed ? colors.success : colors.border,
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: completed
                  ? colors.success
                  : colors.warning.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: LucideIcon(
              iconFor(refeicao.tipo),
              size: 24,
              color: completed ? Colors.white : colors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        refeicao.name,
                        style: AppTypography.inter(
                          size: 16,
                          lineHeight: 24,
                          weight: FontWeight.w600,
                          color: colors.cardForeground,
                        ),
                      ),
                    ),
                    if (completed) ...[
                      const SizedBox(width: 8),
                      Semantics(
                        label: 'Confirmada',
                        child: AppBadge(
                          icon: 'check',
                          backgroundColor: colors.success,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(refeicao.time, style: _small(colors.mutedForeground)),
                const SizedBox(height: 4),
                Text(
                  refeicao.description,
                  style: _small(colors.cardForeground),
                ),
                if (!completed) ...[
                  const SizedBox(height: 8),
                  AppButton(
                    key: ValueKey('confirmar-refeicao-${refeicao.id}'),
                    label: 'Confirmar refeição',
                    variant: AppButtonVariant.outline,
                    color: colors.success,
                    height: 32,
                    horizontalPadding: 12,
                    expand: false,
                    onPressed: onConfirm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card "Hidratação": gota `primary` no título; total / meta (14px,
/// `muted-foreground`) e percentual (16px/600, `primary`) acima da barra de
/// progresso de 12px (`h-3`, 8px abaixo — `mb-2`) e, 16px abaixo
/// (`space-y-4`), os botões `outline` de quantidade, divididos igualmente
/// a 8px um do outro (`flex gap-2`).
class HidratacaoCard extends StatelessWidget {
  const HidratacaoCard({
    super.key,
    required this.hidratacao,
    required this.onAdd,
  });

  final Hidratacao hidratacao;
  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppTitledCard(
      icon: 'droplets',
      iconColor: colors.primary,
      title: 'Hidratação',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${hidratacao.intakeMl}ml / ${hidratacao.goalMl}ml',
                  style: _small(colors.mutedForeground),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${hidratacao.percent}%',
                style: AppTypography.inter(
                  size: 16,
                  lineHeight: 24,
                  weight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgressBar(
            value: hidratacao.progress,
            height: 12,
            semanticLabel: 'Hidratação',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < quantidadesAguaMl.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: '+${quantidadesAguaMl[i]}ml',
                    variant: AppButtonVariant.outline,
                    height: 32,
                    horizontalPadding: 12,
                    onPressed: () => onAdd(quantidadesAguaMl[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Card "Recomendações": cada item com fundo `secondary`, cantos
/// `rounded-lg` e padding de 12px; emoji de 24px a 12px (`gap-3`) do texto
/// de 14px. Itens a 12px um do outro (`space-y-3`).
class RecomendacoesCard extends StatelessWidget {
  const RecomendacoesCard({
    super.key,
    this.recomendacoes = recomendacoesAlimentacao,
  });

  final List<Recomendacao> recomendacoes;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return AppTitledCard(
      title: 'Recomendações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < recomendacoes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.secondary,
                borderRadius: BorderRadius.circular(AppRadius.item),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      recomendacoes[i].emoji,
                      style: AppTypography.inter(size: 24, lineHeight: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recomendacoes[i].text,
                      style: _small(colors.cardForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card "Planejamento Semanal": seta de tendência `primary` no título; os 7
/// dias em colunas iguais a 8px uma da outra (`grid-cols-7 gap-2`), cada
/// uma com a abreviação (12px, `muted-foreground`) e, 8px abaixo (`mb-2`),
/// o círculo de 40px do status:
/// - completo: `success` com check branco de 20px;
/// - parcial: `warning` com "~" branco;
/// - incompleto: `destructive` a 20% com "○" `destructive`.
///
/// 16px abaixo (`mt-4`), a legenda centralizada (bolinhas de 12px a 4px do
/// texto de 12px, itens a 16px um do outro).
///
/// No protótipo, o círculo tem 40px fixos e, em telas estreitas (abaixo de
/// ~412px), a grade transborda o card; aqui o círculo diminui até caber na
/// coluna.
class PlanejamentoSemanalCard extends StatelessWidget {
  const PlanejamentoSemanalCard({super.key, required this.dias});

  final List<DiaPlanejamento> dias;

  static String statusLabel(StatusDiaPlanejamento status) => switch (status) {
    StatusDiaPlanejamento.completo => 'Completo',
    StatusDiaPlanejamento.parcial => 'Parcial',
    StatusDiaPlanejamento.incompleto => 'Incompleto',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final xs = AppTypography.inter(size: 12, lineHeight: 16);

    Widget legend(Color color, StatusDiaPlanejamento status) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          statusLabel(status),
          style: xs.copyWith(color: colors.cardForeground),
        ),
      ],
    );

    return AppTitledCard(
      icon: 'trending-up',
      iconColor: colors.primary,
      title: 'Planejamento Semanal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < dias.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    label: '${dias[i].label}: ${statusLabel(dias[i].status)}',
                    excludeSemantics: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dias[i].label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: xs.copyWith(color: colors.mutedForeground),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) => _StatusCircle(
                            status: dias[i].status,
                            size: math.min(40, constraints.maxWidth),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              legend(colors.success, StatusDiaPlanejamento.completo),
              legend(colors.warning, StatusDiaPlanejamento.parcial),
              legend(
                colors.destructive.withValues(alpha: 0.2),
                StatusDiaPlanejamento.incompleto,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.status, required this.size});

  final StatusDiaPlanejamento status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final (background, foreground) = switch (status) {
      StatusDiaPlanejamento.completo => (colors.success, Colors.white),
      StatusDiaPlanejamento.parcial => (colors.warning, Colors.white),
      StatusDiaPlanejamento.incompleto => (
        colors.destructive.withValues(alpha: 0.2),
        colors.destructive,
      ),
    };
    final text = AppTypography.inter(
      size: 16,
      lineHeight: 24,
      color: foreground,
    );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: switch (status) {
        StatusDiaPlanejamento.completo => LucideIcon(
          'check',
          size: math.min(20, size / 2),
          color: foreground,
        ),
        StatusDiaPlanejamento.parcial => Text('~', style: text),
        StatusDiaPlanejamento.incompleto => Text('○', style: text),
      },
    );
  }
}
