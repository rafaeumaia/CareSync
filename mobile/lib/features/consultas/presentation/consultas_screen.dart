import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/session/current_user.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_segmented_tabs.dart';
import '../../../core/widgets/bottom_nav_shell.dart';
import '../../../core/widgets/header_screen_layout.dart';
import '../state/consultas_providers.dart';
import 'widgets/consulta_cards.dart';
import 'widgets/nova_consulta_dialog.dart';

/// Consultas / Agenda (PROJECT_SPEC.md, seção 2), fiel a
/// `ConsultasScreen.tsx` do protótipo Figma Make:
/// - header padrão; abas "Próximas" / "Passadas" filtradas pela data;
/// - "Próximas": cards com excluir (funcional) e editar (sem ação no
///   protótipo); estado vazio com estetoscópio;
/// - "Passadas": cards esmaecidos, sem ações; estado vazio só com texto;
/// - FAB (+) abre o diálogo "Nova Consulta", que adiciona na lista.
///
/// Correções de inconsistências do protótipo (CLAUDE.md): o protótipo
/// interpreta `'aaaa-mm-dd'` em UTC, o que no Brasil exibia a data um dia
/// antes e mandava as consultas do próprio dia para "Passadas"; aqui a data
/// é tratada como dia local. Cores hardcoded viram tokens do tema.
class ConsultasScreen extends ConsumerStatefulWidget {
  const ConsultasScreen({super.key});

  @override
  ConsumerState<ConsultasScreen> createState() => _ConsultasScreenState();
}

class _ConsultasScreenState extends ConsumerState<ConsultasScreen> {
  static const _upcomingTab = 0;

  int _selectedTab = _upcomingTab;
  final _form = NovaConsultaForm();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _openNovaConsulta() {
    showNovaConsultaDialog(
      context: context,
      form: _form,
      today: ref.read(currentDateProvider),
      onAdd: ref.read(consultasProvider.notifier).add,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final today = ref.watch(currentDateProvider);
    final consultas = ref.watch(consultasProvider).value;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final horizontalPadding = isTablet
        ? AppSpacing.screenPaddingTablet
        : AppSpacing.screenPaddingMobile;

    final upcoming = [
      for (final c in consultas ?? const []) if (c.isUpcoming(today)) c,
    ];
    final past = [
      for (final c in consultas ?? const []) if (!c.isUpcoming(today)) c,
    ];
    final showingUpcoming = _selectedTab == _upcomingTab;

    final List<Widget> items;
    if (consultas == null) {
      items = const [];
    } else if (showingUpcoming) {
      items = upcoming.isEmpty
          ? const [
              ConsultasEmptyState(
                icon: 'stethoscope',
                message: 'Nenhuma consulta agendada',
              ),
            ]
          : [
              for (final c in upcoming)
                UpcomingConsultaCard(
                  key: ValueKey('consulta-${c.id}'),
                  consulta: c,
                  onDelete: () =>
                      ref.read(consultasProvider.notifier).delete(c.id),
                ),
            ];
    } else {
      items = past.isEmpty
          ? const [ConsultasEmptyState(message: 'Nenhuma consulta passada')]
          : [
              for (final c in past)
                PastConsultaCard(key: ValueKey('consulta-${c.id}'), consulta: c),
            ];
    }

    return HeaderScreenLayout(
      header: AppHeader(
        userName: user.name,
        notificationCount: user.notificationCount,
        onAvatarTap: () => context.push(RoutePaths.perfil),
      ),
      fab: AppFab(
        semanticLabel: 'Nova consulta',
        onPressed: _openNovaConsulta,
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
            AppSegmentedTabs(
              labels: const ['Próximas', 'Passadas'],
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            // `gap-2` do Tabs + `mb-6` da lista de abas.
            const SizedBox(height: 32),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              items[i],
            ],
          ],
        ),
      ),
    );
  }
}
