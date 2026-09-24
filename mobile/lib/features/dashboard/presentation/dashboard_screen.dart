import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/bottom_nav_shell.dart';
import '../domain/dashboard_summary.dart';
import '../state/dashboard_providers.dart';
import 'widgets/dashboard_widgets.dart';

/// Dashboard / Início (PROJECT_SPEC.md, seção 2), fiel a `Dashboard.tsx`
/// do protótipo Figma Make.
///
/// Navegação (a mesma do protótipo):
/// - avatar do header → Perfil;
/// - card "Próxima em" e FAB (+) → Consultas (aba Agenda);
/// - card "Medicações" → Medicações;
/// - ações rápidas → Indicadores (aba Saúde), Alimentação e Relatórios.
///
/// Correções de inconsistências do protótipo (CLAUDE.md): cores
/// hardcoded (`bg-white`, `#2F80ED`, `#27AE60`, `#EB5757`) viram os tokens
/// `card`, `primary`, `success` e `destructive`, respeitando o dark mode; e
/// a data abaixo do header, fixa no protótipo ("Segunda-feira, 27 de
/// Outubro"), mostra a data de hoje no mesmo formato.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.careSyncColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(dashboardSummaryProvider).value;
    final today = ref.watch(todayProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: ColoredBox(
        color: colors.background,
        child: summary == null
            ? const SizedBox.expand()
            : Stack(
                children: [
                  // `VerticalDirection.up` mantém o header no topo mas o
                  // pinta por último, para que a sombra dele fique sobre o
                  // conteúdo rolado (`sticky top-0 z-10`).
                  Column(
                    verticalDirection: VerticalDirection.up,
                    children: [
                      Expanded(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: _DashboardContent(
                            summary: summary,
                            today: today,
                          ),
                        ),
                      ),
                      AppHeader(
                        userName: summary.userName,
                        notificationCount: summary.notificationCount,
                        onAvatarTap: () => context.push(RoutePaths.perfil),
                      ),
                    ],
                  ),
                  Positioned(
                    right: AppFab.right,
                    bottom: AppFab.bottom,
                    child: AppFab(
                      semanticLabel: 'Nova consulta',
                      onPressed: () => context.go(RoutePaths.consultas),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.summary, required this.today});

  final DashboardSummary summary;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    // `px-4 md:px-6` e `mb-3 md:mb-4`.
    final horizontalPadding = isTablet
        ? AppSpacing.screenPaddingTablet
        : AppSpacing.screenPaddingMobile;
    final sectionGap =
        isTablet ? AppSpacing.sectionGapTablet : AppSpacing.sectionGapMobile;
    final days = summary.daysUntilNextAppointment;

    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Data do dia: `bg-white px-6 py-3` com a sombra padrão.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.card,
                  boxShadow: AppShadows.card,
                ),
                child: Text(
                  formatWeekdayDayMonth(today),
                  style: AppTypography.inter(
                    size: 14,
                    lineHeight: 20,
                    color: colors.mutedForeground,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  // `pb-20` da tela menos os 68px do BottomNav.
                  80 - AppBottomNav.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EqualHeightRow(
                      children: [
                        QuickAccessCard(
                          icon: 'stethoscope',
                          color: colors.primary,
                          label: 'Próxima em',
                          value: days == 1 ? '1 dia' : '$days dias',
                          onTap: () => context.go(RoutePaths.consultas),
                        ),
                        QuickAccessCard(
                          icon: 'pill',
                          color: colors.success,
                          label: 'Medicações',
                          value: '${summary.medicationsToday} hoje',
                          onTap: () => context.push(RoutePaths.medicacoes),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),
                    TasksOfTheDayCard(tasks: summary.tasks),
                    SizedBox(height: sectionGap),
                    _EqualHeightRow(
                      children: [
                        QuickActionButton(
                          icon: 'heart_outline',
                          color: colors.destructive,
                          label: 'Indicadores',
                          onTap: () => context.go(RoutePaths.indicadores),
                        ),
                        QuickActionButton(
                          icon: 'utensils',
                          color: colors.success,
                          label: 'Alimentação',
                          onTap: () => context.push(RoutePaths.alimentacao),
                        ),
                        QuickActionButton(
                          icon: 'file-text',
                          color: colors.primary,
                          label: 'Relatórios',
                          onTap: () => context.go(RoutePaths.relatorios),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),
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

/// Linha de colunas iguais com 12px entre elas (`grid grid-cols-N gap-3`),
/// esticando todos os itens até a altura do mais alto, como no grid CSS.
class _EqualHeightRow extends StatelessWidget {
  const _EqualHeightRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: children[i]),
          ],
        ],
      ),
    );
  }
}
