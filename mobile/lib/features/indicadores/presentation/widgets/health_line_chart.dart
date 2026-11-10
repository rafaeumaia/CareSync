import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/indicador.dart';
import 'chart_scale.dart';

/// Uma linha do gráfico.
class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.color,
    required this.values,
  });

  /// Nome mostrado no tooltip (ex.: "Sistólica").
  final String name;
  final Color color;
  final List<double> values;
}

/// Gráfico de linha dos indicadores, reproduzindo o `LineChart` do Recharts
/// usado no protótipo (`ResponsiveContainer height={200}`):
/// - margens de 5px, eixo Y com 60px e eixo X com 30px de altura;
/// - um ponto por medição, igualmente espaçados (eixo de categorias, como
///   no protótipo); com muitas medições, os rótulos e a grade vertical
///   aparecem a cada N pontos para não se sobreporem; uma medição só fica
///   centralizada;
/// - grade tracejada `3 3` em `#f0f0f0` nos ticks dos dois eixos;
/// - eixos e rótulos de 12px em `#999`, com marcas de 6px e 2px até o
///   texto; eixo Y ajustado aos dados visíveis ([niceAxisRange]);
/// - linhas suaves (`type="monotone"`) de 2px com pontos de raio 3
///   (preenchidos com a cor do card e contorno na cor da linha);
/// - ao tocar, cursor vertical `#ccc`, ponto ativo de raio 4 e o tooltip
///   padrão do Recharts (fundo do card, borda `#ccc`, padding de 10px, o
///   rótulo da medição e "Nome : valor" na cor de cada linha).
///
/// No tema escuro, a grade usa a cor `border` do tema (a `#f0f0f0` fixa do
/// protótipo ficaria clara demais sobre o card escuro).
class HealthLineChart extends StatelessWidget {
  const HealthLineChart({
    super.key,
    required this.labels,
    required this.tooltipLabels,
    required this.series,
  });

  /// Rótulos do eixo X, um por medição (ex.: "Seg", "22/10").
  final List<String> labels;

  /// Rótulo de cada medição no tooltip (ex.: "22/10 08:00").
  final List<String> tooltipLabels;
  final List<ChartSeries> series;

  static const height = 200.0;

  /// Máximo de rótulos no eixo X.
  static const maxXLabels = 7;
  static const _axisColor = Color(0xFF999999);
  static const _lightGridColor = Color(0xFFF0F0F0);
  static const _cursorColor = Color(0xFFCCCCCC);

  /// Intervalo entre rótulos do eixo X para [count] medições.
  static int labelInterval(int count) =>
      count <= maxXLabels ? 1 : (count / maxXLabels).ceil();

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridColor = isDark ? colors.border : _lightGridColor;

    final count = labels.length;
    // Uma medição só: fica no meio do eixo (x = 1 de 0 a 2).
    final xOffset = count == 1 ? 1 : 0;
    final maxX = count == 1 ? 2.0 : (count - 1).toDouble();
    final interval = labelInterval(count).toDouble();

    final range = niceAxisRange(series.expand((s) => s.values));

    final tickStyle = AppTypography.inter(
      size: 12,
      lineHeight: 16,
      color: _axisColor,
    );
    final gridLine = FlLine(
      color: gridColor,
      strokeWidth: 1,
      dashArray: const [3, 3],
    );

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: range.min,
            maxY: range.max,
            gridData: FlGridData(
              horizontalInterval: range.step,
              verticalInterval: interval,
              getDrawingHorizontalLine: (_) => gridLine,
              getDrawingVerticalLine: (_) => gridLine,
            ),
            borderData: FlBorderData(
              border: const Border(
                left: BorderSide(color: _axisColor),
                bottom: BorderSide(color: _axisColor),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  interval: range.step,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    space: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatMeasurement(value), style: tickStyle),
                        const SizedBox(width: 2),
                        Container(width: 6, height: 1, color: _axisColor),
                      ],
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    final index = value.round() - xOffset;
                    if ((value - value.round()).abs() > 0.01 ||
                        index < 0 ||
                        index >= count) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      space: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 1, height: 6, color: _axisColor),
                          const SizedBox(height: 2),
                          Text(labels[index], style: tickStyle),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              getTouchLineStart: (_, _) => range.min,
              getTouchLineEnd: (_, _) => range.max,
              getTouchedSpotIndicator: (bar, indexes) => [
                for (final _ in indexes)
                  TouchedSpotIndicatorData(
                    const FlLine(color: _cursorColor, strokeWidth: 1),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: bar.color ?? colors.primary,
                            strokeColor: colors.card,
                            strokeWidth: 2,
                          ),
                    ),
                  ),
              ],
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.card,
                tooltipBorder: const BorderSide(color: _cursorColor),
                tooltipBorderRadius: BorderRadius.zero,
                tooltipPadding: const EdgeInsets.all(10),
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                maxContentWidth: 220,
                getTooltipItems: (spots) {
                  final sorted = [...spots]
                    ..sort((a, b) => a.barIndex.compareTo(b.barIndex));
                  final index = sorted.first.x.round() - xOffset;
                  final itemStyle = AppTypography.inter(
                    size: 16,
                    lineHeight: 32,
                  );
                  final first = LineTooltipItem(
                    tooltipLabels[index],
                    AppTypography.inter(
                      size: 16,
                      lineHeight: 24,
                      color: colors.foreground,
                    ),
                    textAlign: TextAlign.start,
                    children: [
                      for (final spot in sorted)
                        TextSpan(
                          text:
                              '\n${series[spot.barIndex].name} : '
                              '${formatMeasurement(spot.y)}',
                          style: itemStyle.copyWith(
                            color: series[spot.barIndex].color,
                          ),
                        ),
                    ],
                  );
                  return [
                    for (var i = 0; i < spots.length; i++)
                      spots[i] == sorted.first ? first : null,
                  ];
                },
              ),
            ),
            lineBarsData: [
              for (final s in series)
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < s.values.length; i++)
                      FlSpot((i + xOffset).toDouble(), s.values[i]),
                  ],
                  color: s.color,
                  barWidth: 2,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  dotData: FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: colors.card,
                          strokeColor: s.color,
                          strokeWidth: 2,
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

/// Legenda do gráfico de pressão: bolinhas de 12px a 8px do nome (14px,
/// `muted-foreground`), itens a 24px um do outro, centralizados.
class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.items});

  final List<({String label, Color color})> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 8,
      children: [
        for (final item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.label,
                style: AppTypography.inter(
                  size: 14,
                  lineHeight: 20,
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
