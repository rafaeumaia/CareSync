import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/session/current_user.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_segmented_tabs.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bottom_nav_shell.dart';
import '../../../core/widgets/header_screen_layout.dart';
import '../domain/indicador.dart';
import '../state/indicadores_providers.dart';
import 'widgets/adicionar_indicador_dialog.dart';
import 'widgets/indicator_card.dart';
import 'widgets/indicator_chart_card.dart';

/// Indicadores / Saúde (PROJECT_SPEC.md, seção 2), fiel a
/// `IndicadoresScreen.tsx` do protótipo Figma Make:
/// - header padrão; grade 2×2 com Pressão Arterial, Glicemia, Temperatura e
///   Peso, cada um com a medição mais recente;
/// - gráficos de linha do histórico (pressão com sistólica e diastólica e
///   legenda);
/// - "Gerar Relatório Completo (PDF)" só mostra um toast, como no protótipo
///   (a geração real fica para a feature Relatórios);
/// - FAB verde abre "Adicionar Indicador"; BottomNav com "Saúde" ativa.
///
/// Melhorias aprovadas além do protótipo: "Adicionar Registro" salva a
/// medição (com validação), gráficos também para Temperatura e Peso, escolha
/// de período (7/30/90 dias, nas abas do design system) e eixo Y ajustado
/// aos dados. Cores hardcoded viram tokens do tema.
class IndicadoresScreen extends ConsumerStatefulWidget {
  const IndicadoresScreen({super.key});

  @override
  ConsumerState<IndicadoresScreen> createState() => _IndicadoresScreenState();
}

class _IndicadoresScreenState extends ConsumerState<IndicadoresScreen> {
  /// Indicador escolhido no diálogo (`selectedIndicator` do protótipo):
  /// continua marcado ao reabrir.
  final _selectedIndicator = ValueNotifier<IndicatorType?>(null);

  /// Período dos gráficos; 7 dias, como no protótipo.
  ChartPeriod _period = ChartPeriod.week;

  @override
  void dispose() {
    _selectedIndicator.dispose();
    super.dispose();
  }

  void _openAdicionar() {
    showAdicionarIndicadorDialog(
      context: context,
      selected: _selectedIndicator,
      clock: ref.read(clockProvider),
      onAdd: (draft) async {
        await ref.read(indicadoresProvider.notifier).add(draft);
        if (mounted) {
          showAppSuccessToast(context, 'Indicador registrado com sucesso!');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final user = ref.watch(currentUserProvider);
    final today = ref.watch(currentDateProvider);
    final records = ref.watch(indicadoresProvider).value;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final horizontalPadding = isTablet
        ? AppSpacing.screenPaddingTablet
        : AppSpacing.screenPaddingMobile;
    // `space-y-4 md:space-y-6`.
    final gap = isTablet ? 24.0 : 16.0;

    final sections = <Widget>[
      if (records != null) ...[
        _IndicatorGrid(records: records),
        AppSegmentedTabs(
          labels: [for (final p in ChartPeriod.values) p.label],
          selectedIndex: _period.index,
          onChanged: (index) =>
              setState(() => _period = ChartPeriod.values[index]),
        ),
        for (final type in IndicatorType.values)
          IndicatorChartCard(
            type: type,
            period: _period,
            records: recordsInPeriod(records, type, _period, today),
          ),
      ],
      AppButton(
        label: 'Gerar Relatório Completo (PDF)',
        icon: 'file-down',
        iconSize: 20,
        // `gap-2` do botão + `mr-2` do ícone.
        iconSpacing: 16,
        color: colors.success,
        onPressed: () =>
            showAppSuccessToast(context, 'Relatório gerado com sucesso!'),
      ),
    ];

    return HeaderScreenLayout(
      header: AppHeader(
        userName: user.name,
        notificationCount: user.notificationCount,
        onAvatarTap: () => context.push(RoutePaths.perfil),
      ),
      fab: AppFab(
        semanticLabel: 'Adicionar indicador',
        color: colors.success,
        onPressed: _openAdicionar,
      ),
      body: Padding(
        // `px-4 md:px-6 py-6` + `pb-20` da tela menos os 68px do BottomNav.
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          24,
          horizontalPadding,
          24 + 80 - AppBottomNav.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              sections[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// `grid grid-cols-2 gap-4`: um card por indicador, com a medição mais
/// recente; cards de mesma altura em cada linha.
class _IndicatorGrid extends StatelessWidget {
  const _IndicatorGrid({required this.records});

  final List<IndicatorRecord> records;

  @override
  Widget build(BuildContext context) {
    const types = IndicatorType.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var row = 0; row < types.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < 2; col++) ...[
                  if (col > 0) const SizedBox(width: 16),
                  Expanded(
                    child: IndicatorCard(
                      type: types[row + col],
                      latest: latestRecord(records, types[row + col]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
