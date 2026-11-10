import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_fab.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/bottom_nav_shell.dart';
import '../../../core/widgets/colored_back_header.dart';
import '../../../core/widgets/sub_screen_layout.dart';
import '../domain/refeicao.dart';
import '../state/alimentacao_providers.dart';
import 'widgets/adicionar_refeicao_dialog.dart';
import 'widgets/alimentacao_cards.dart';

/// Alimentação (PROJECT_SPEC.md, seção 2), fiel a `AlimentacaoScreen.tsx`
/// do protótipo Figma Make:
/// - header verde com voltar (para o Início), título e subtítulo;
/// - "Refeições do Dia": "Confirmar refeição" confirma a refeição e mostra
///   um toast (no protótipo não há como desfazer);
/// - "Hidratação": os botões somam água até a meta diária, com toast;
/// - "Recomendações" e "Planejamento Semanal", com conteúdo fixo;
/// - FAB verde (+) abre "Adicionar Refeição", que, como no protótipo, só
///   mostra um toast;
/// - BottomNav sem aba ativa.
///
/// Cores hardcoded (`#27AE60`, `#F2994A`, `#EB5757`, `#2F80ED`,
/// `bg-white`) viram os tokens `success`, `warning`, `destructive`,
/// `primary` e `card`.
class AlimentacaoScreen extends ConsumerWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.careSyncColors;
    final refeicoes = ref.watch(refeicoesProvider).value;
    final hidratacao = ref.watch(hidratacaoProvider).value;
    final planejamento = ref.watch(planejamentoSemanalProvider).value;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final horizontalPadding = isTablet
        ? AppSpacing.screenPaddingTablet
        : AppSpacing.screenPaddingMobile;
    // `space-y-4 md:space-y-6`.
    final gap = isTablet ? 24.0 : 16.0;

    void back() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(RoutePaths.dashboard);
      }
    }

    Future<void> confirm(Refeicao refeicao) async {
      final updated = await ref
          .read(refeicoesProvider.notifier)
          .toggle(refeicao.id);
      if (updated != null && updated.completed && context.mounted) {
        showAppSuccessToast(context, '${updated.name} confirmado!');
      }
    }

    Future<void> addAgua(int amountMl) async {
      await ref.read(hidratacaoProvider.notifier).addAgua(amountMl);
      if (context.mounted) {
        showAppSuccessToast(context, '+${amountMl}ml de água registrado!');
      }
    }

    final items = <Widget>[
      RefeicoesDoDiaCard(refeicoes: refeicoes ?? const [], onConfirm: confirm),
      if (hidratacao != null)
        HidratacaoCard(hidratacao: hidratacao, onAdd: addAgua),
      const RecomendacoesCard(),
      if (planejamento != null) PlanejamentoSemanalCard(dias: planejamento),
    ];

    return SubScreenLayout(
      statusBarColor: colors.success,
      header: ColoredBackHeader(
        color: colors.success,
        title: 'Alimentação 🥗',
        subtitle: 'Mantenha uma alimentação equilibrada e saudável',
        onBack: back,
      ),
      fab: AppFab(
        semanticLabel: 'Adicionar refeição',
        color: colors.success,
        onPressed: () => showAdicionarRefeicaoDialog(
          context: context,
          onAdd: () => showAppSuccessToast(context, 'Refeição adicionada!'),
        ),
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
