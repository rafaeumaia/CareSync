import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_titled_card.dart';
import '../../domain/indicador.dart';
import 'health_line_chart.dart';
import 'indicator_card.dart';

/// Card com o histórico de um indicador no [period] escolhido, como os
/// cards "Pressão Arterial (7 dias)" e "Glicemia (7 dias)" do protótipo:
/// título com o ícone de 20px na cor do indicador e o [HealthLineChart].
///
/// - Pressão arterial: linhas "Sistólica" (`destructive`) e "Diastólica"
///   (`primary`) com a legenda 16px abaixo, como no protótipo;
/// - demais indicadores: uma linha na cor do indicador, sem legenda;
/// - eixo X: dia da semana ("Seg") em 7 dias, ou `dd/mm` em 30/90 dias;
/// - sem medições no período: mensagem no lugar do gráfico, com a mesma
///   altura.
class IndicatorChartCard extends StatelessWidget {
  const IndicatorChartCard({
    super.key,
    required this.type,
    required this.period,
    required this.records,
  });

  final IndicatorType type;
  final ChartPeriod period;

  /// Medições do período, da mais antiga para a mais recente.
  final List<IndicatorRecord> records;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final style = indicatorStyle(context, type);
    final isPressure = type == IndicatorType.pressure;

    final Widget content;
    if (records.isEmpty) {
      content = SizedBox(
        height: HealthLineChart.height,
        child: Center(
          child: Text(
            'Nenhum registro no período',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 14,
              lineHeight: 20,
              color: colors.mutedForeground,
            ),
          ),
        ),
      );
    } else {
      final chart = HealthLineChart(
        key: ValueKey('grafico-${type.name}'),
        labels: [
          for (final r in records)
            period == ChartPeriod.week
                ? formatShortWeekday(r.recordedAt)
                : formatDdMm(r.recordedAt),
        ],
        tooltipLabels: [
          for (final r in records)
            '${formatDdMm(r.recordedAt)} '
                '${formatHhMm(r.recordedAt.hour, r.recordedAt.minute)}',
        ],
        series: isPressure
            ? [
                ChartSeries(
                  name: 'Sistólica',
                  color: colors.destructive,
                  values: [for (final r in records) r.value],
                ),
                ChartSeries(
                  name: 'Diastólica',
                  color: colors.primary,
                  values: [for (final r in records) r.diastolic!],
                ),
              ]
            : [
                ChartSeries(
                  name: type.label,
                  color: style.color,
                  values: [for (final r in records) r.value],
                ),
              ],
      );
      content = isPressure
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                chart,
                const SizedBox(height: 16),
                ChartLegend(
                  items: [
                    (label: 'Sistólica', color: colors.destructive),
                    (label: 'Diastólica', color: colors.primary),
                  ],
                ),
              ],
            )
          : chart;
    }

    return AppTitledCard(
      key: ValueKey('card-grafico-${type.name}'),
      icon: style.icon,
      iconColor: style.color,
      title: '${type.label} (${period.label})',
      child: content,
    );
  }
}
