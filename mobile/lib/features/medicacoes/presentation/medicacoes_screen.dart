import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bottom_nav_shell.dart';
import '../../../core/widgets/colored_back_header.dart';
import '../../../core/widgets/sub_screen_layout.dart';
import '../domain/medicacao.dart';
import '../state/medicacoes_providers.dart';
import 'widgets/adicionar_medicacao_dialog.dart';
import 'widgets/medicacao_cards.dart';

/// Minhas Medicações (PROJECT_SPEC.md, seção 2), fiel a
/// `MedicacoesScreen.tsx` do protótipo Figma Make:
/// - header verde com voltar (para o Início), título e subtítulo;
/// - cards de medicação com o estado tomado/não tomado; "Marcar como
///   tomado" marca a medicação e mostra um toast (no protótipo não há como
///   desmarcar nem excluir);
/// - estado vazio com a pílula; card informativo "Lembre-se";
/// - FAB verde (+) abre "Adicionar Medicação", que adiciona na lista e
///   mostra um toast;
/// - BottomNav sem aba ativa.
///
/// Melhorias aprovadas além do protótipo: excluir (com confirmação e
/// toast), desmarcar "tomado" (com toast) e lembretes locais reais nos
/// horários cadastrados — a permissão de notificações é pedida ao abrir a
/// tela, onde o card "Lembre-se" explica os lembretes. Cores hardcoded (`#27AE60`, `#2F80ED`, `#56CCF2`,
/// `bg-white`) viram os tokens `success`, `primary`, `accent` e `card`.
class MedicacoesScreen extends ConsumerStatefulWidget {
  const MedicacoesScreen({super.key});

  @override
  ConsumerState<MedicacoesScreen> createState() => _MedicacoesScreenState();
}

class _MedicacoesScreenState extends ConsumerState<MedicacoesScreen> {
  final _form = AdicionarMedicacaoForm();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(medicacaoReminderSchedulerProvider).requestPermissions();
      }
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.dashboard);
    }
  }

  void _openAdicionar() {
    showAdicionarMedicacaoDialog(
      context: context,
      form: _form,
      onAdd: (draft) async {
        await ref.read(medicacoesProvider.notifier).add(draft);
        if (mounted) {
          showAppSuccessToast(context, 'Medicação adicionada com sucesso!');
        }
      },
    );
  }

  Future<void> _setTaken(Medicacao medicacao, {required bool taken}) async {
    final changed = await ref
        .read(medicacoesProvider.notifier)
        .setTaken(medicacao.id, taken: taken);
    if (!changed || !mounted) return;
    showAppSuccessToast(
      context,
      taken
          ? '${medicacao.name} marcado como tomado!'
          : '${medicacao.name} desmarcado como tomado!',
    );
  }

  Future<void> _confirmDelete(Medicacao medicacao) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Deseja excluir ${medicacao.name}?',
      description:
          'A medicação será removida da lista e os lembretes '
          'dela serão cancelados.',
      confirmLabel: 'Excluir',
      confirmColor: context.careSyncColors.destructive,
    );
    if (!confirmed || !mounted) return;
    final deleted = await ref
        .read(medicacoesProvider.notifier)
        .delete(medicacao.id);
    if (deleted != null && mounted) {
      showAppSuccessToast(context, 'Medicação excluída com sucesso!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final medicacoes = ref.watch(medicacoesProvider).value;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final horizontalPadding = isTablet
        ? AppSpacing.screenPaddingTablet
        : AppSpacing.screenPaddingMobile;
    final gap = isTablet
        ? AppSpacing.sectionGapTablet
        : AppSpacing.sectionGapMobile;

    final items = <Widget>[
      if (medicacoes != null && medicacoes.isEmpty)
        const AppEmptyState(
          icon: 'pill',
          message: 'Nenhuma medicação cadastrada',
        )
      else
        for (final m in medicacoes ?? const <Medicacao>[])
          MedicacaoCard(
            key: ValueKey('medicacao-${m.id}'),
            medicacao: m,
            onMarkTaken: () => _setTaken(m, taken: true),
            onUnmarkTaken: () => _setTaken(m, taken: false),
            onDelete: () => _confirmDelete(m),
          ),
      const LembreteInfoCard(),
    ];

    return SubScreenLayout(
      statusBarColor: colors.success,
      header: ColoredBackHeader(
        color: colors.success,
        title: 'Minhas Medicações',
        subtitle: 'Gerencie os medicamentos diários',
        onBack: _back,
      ),
      fab: AppFab(
        semanticLabel: 'Adicionar medicação',
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
            // `space-y-3 md:space-y-4`.
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              items[i],
            ],
          ],
        ),
      ),
    );
  }
}
