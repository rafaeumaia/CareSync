import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/app_router.dart';
import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/core/widgets/app_badge.dart';
import 'package:caresync/core/widgets/app_progress_bar.dart';
import 'package:caresync/core/widgets/bottom_nav_shell.dart';
import 'package:caresync/core/widgets/lucide_icon.dart';
import 'package:caresync/features/alimentacao/data/alimentacao_repository.dart';
import 'package:caresync/features/alimentacao/presentation/alimentacao_screen.dart';
import 'package:caresync/features/alimentacao/presentation/widgets/alimentacao_cards.dart';
import 'package:caresync/features/alimentacao/state/alimentacao_providers.dart';
import 'package:caresync/features/dashboard/presentation/dashboard_screen.dart';
import 'package:caresync/main.dart';

Widget _stub(String name) => Scaffold(body: Center(child: Text('$name stub')));

Future<void> _pumpAlimentacao(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      // Repositório novo a cada teste.
      overrides: [
        alimentacaoRepositoryProvider.overrideWithValue(
          InMemoryAlimentacaoRepository(),
        ),
      ],
      child: MaterialApp.router(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: GoRouter(
          initialLocation: RoutePaths.alimentacao,
          routes: [
            GoRoute(
              path: RoutePaths.alimentacao,
              builder: (context, state) => const AlimentacaoScreen(),
            ),
            for (final (path, name) in [
              (RoutePaths.dashboard, 'Dashboard'),
              (RoutePaths.consultas, 'Consultas'),
              (RoutePaths.indicadores, 'Indicadores'),
              (RoutePaths.relatorios, 'Relatórios'),
            ])
              GoRoute(path: path, builder: (context, state) => _stub(name)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Deixa os toasts (4s) terminarem.
Future<void> _waitToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Finder _meal(String id) => find.byKey(ValueKey('refeicao-$id'));
Finder _confirm(String id) => find.byKey(ValueKey('confirmar-refeicao-$id'));
Finder _inMeal(String id, Finder finder) =>
    find.descendant(of: _meal(id), matching: finder);

BoxDecoration _mealDecoration(WidgetTester tester, String id) =>
    tester
            .widget<AnimatedContainer>(
              _inMeal(id, find.byType(AnimatedContainer)).first,
            )
            .decoration!
        as BoxDecoration;

Color _mealIconColor(WidgetTester tester, String id) => tester
    .widget<LucideIcon>(_inMeal(id, find.byType(LucideIcon)).first)
    .color!;

double _progress(WidgetTester tester) =>
    tester.widget<AppProgressBar>(find.byType(AppProgressBar)).value;

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  // Centralizado, para não ficar sob o toast (topo) nem sob o FAB.
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Lido dentro dos testes: o tema usa `google_fonts`, que exige a binding.
CareSyncColors get _colors => AppTheme.light.extension<CareSyncColors>()!;

void main() {
  testWidgets('Mostra header, refeições, hidratação, recomendações e semana', (
    tester,
  ) async {
    await _pumpAlimentacao(tester);

    expect(find.text('Alimentação 🥗'), findsOneWidget);
    expect(
      find.text('Mantenha uma alimentação equilibrada e saudável'),
      findsOneWidget,
    );
    expect(find.text('Refeições do Dia'), findsOneWidget);

    for (final text in [
      'Café da manhã',
      '07:00',
      'Leite + pão integral + fruta',
      'Almoço',
      '12:00',
      'Arroz + feijão + frango + salada',
      'Lanche',
      '15:00',
      'Iogurte + castanhas',
      'Jantar',
      '19:00',
      'Sopa leve + legumes',
      'Hidratação',
      '1200ml / 2000ml',
      '60%',
      '+200ml',
      '+300ml',
      '+500ml',
      'Recomendações',
      'Prefira alimentos ricos em fibras.',
      'Evite excesso de sal e açúcar.',
      'Inclua frutas todos os dias.',
      'Planejamento Semanal',
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom',
      'Completo',
      'Parcial',
      'Incompleto',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(_progress(tester), closeTo(0.6, 1e-9));

    // Café e almoço confirmados; lanche e jantar pendentes.
    for (final id in ['breakfast', 'lunch']) {
      expect(_inMeal(id, find.byType(AppBadge)), findsOneWidget);
      expect(_confirm(id), findsNothing);
      expect(_mealIconColor(tester, id), Colors.white);
      expect(
        (_mealDecoration(tester, id).border! as Border).top.color,
        _colors.success,
      );
    }
    for (final id in ['snack', 'dinner']) {
      expect(_inMeal(id, find.byType(AppBadge)), findsNothing);
      expect(_confirm(id), findsOneWidget);
      expect(_mealIconColor(tester, id), _colors.warning);
      expect(
        (_mealDecoration(tester, id).border! as Border).top.color,
        _colors.border,
      );
    }

    // Planejamento: 3 completos (check), 1 parcial (~), 3 incompletos (○).
    final semana = find.byType(PlanejamentoSemanalCard);
    expect(
      find.descendant(of: semana, matching: find.byType(LucideIcon)),
      findsNWidgets(4), // 3 checks + ícone do título.
    );
    expect(
      find.descendant(of: semana, matching: find.text('~')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: semana, matching: find.text('○')),
      findsNWidgets(3),
    );
  });

  testWidgets('Confirmar refeição marca como concluída e mostra toast', (
    tester,
  ) async {
    await _pumpAlimentacao(tester);

    await _tapVisible(tester, _confirm('snack'));

    expect(find.text('Lanche confirmado!'), findsOneWidget);
    expect(_confirm('snack'), findsNothing);
    expect(_inMeal('snack', find.byType(AppBadge)), findsOneWidget);
    expect(_mealIconColor(tester, 'snack'), Colors.white);
    expect(
      (_mealDecoration(tester, 'snack').border! as Border).top.color,
      _colors.success,
    );
    // O jantar continua pendente.
    expect(_confirm('dinner'), findsOneWidget);

    await _tapVisible(tester, _confirm('dinner'));
    expect(find.text('Jantar confirmado!'), findsOneWidget);
    expect(find.text('Confirmar refeição'), findsNothing);
    await _waitToasts(tester);
  });

  testWidgets('Hidratação soma água, atualiza o progresso e para na meta', (
    tester,
  ) async {
    await _pumpAlimentacao(tester);

    await _tapVisible(tester, find.text('+200ml'));
    expect(find.text('1400ml / 2000ml'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(_progress(tester), closeTo(0.7, 1e-9));
    expect(find.text('+200ml de água registrado!'), findsOneWidget);

    await _tapVisible(tester, find.text('+300ml'));
    expect(find.text('1700ml / 2000ml'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    await _waitToasts(tester);

    // 1700 + 500 passaria da meta: fica em 2000ml (100%), e o toast aparece
    // como no protótipo.
    await _tapVisible(tester, find.text('+500ml'));
    expect(find.text('2000ml / 2000ml'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(_progress(tester), 1);
    expect(find.text('+500ml de água registrado!'), findsOneWidget);

    await _tapVisible(tester, find.text('+200ml'));
    expect(find.text('2000ml / 2000ml'), findsOneWidget);
    await _waitToasts(tester);
  });

  testWidgets('FAB abre "Adicionar Refeição"; Adicionar fecha e mostra toast', (
    tester,
  ) async {
    await _pumpAlimentacao(tester);

    await tester.tap(find.bySemanticsLabel('Adicionar refeição'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Refeição'), findsOneWidget);
    for (final text in [
      'Nome da refeição',
      'Ex: Lanche da tarde',
      'Horário',
      '--:--',
      'Descrição',
      'O que foi consumido...',
      'Adicionar',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.enterText(
      find.widgetWithText(TextField, 'Ex: Lanche da tarde'),
      'Ceia',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'O que foi consumido...'),
      'Chá + torrada',
    );
    await tester.tap(find.text('--:--'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('--:--'), findsNothing);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Refeição'), findsNothing);
    expect(find.text('Refeição adicionada!'), findsOneWidget);
    // Como no protótipo, a refeição não entra na lista.
    expect(find.text('Ceia'), findsNothing);
    expect(find.byType(RefeicaoItem), findsNWidgets(4));

    // O formulário começa vazio a cada abertura.
    await tester.tap(find.bySemanticsLabel('Adicionar refeição'));
    await tester.pumpAndSettle();
    expect(find.text('Ceia'), findsNothing);
    expect(find.text('--:--'), findsOneWidget);

    // Fechar pelo X não mostra toast.
    await tester.tap(find.bySemanticsLabel('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Refeição'), findsNothing);
    await _waitToasts(tester);
    expect(find.text('Refeição adicionada!'), findsNothing);
  });

  testWidgets('Voltar leva ao Início; BottomNav sem aba ativa leva às abas', (
    tester,
  ) async {
    await _pumpAlimentacao(tester);

    expect(
      tester.widget<AppBottomNav>(find.byType(AppBottomNav)).currentIndex,
      -1,
    );

    await tester.tap(find.text('Saúde'));
    await tester.pumpAndSettle();
    expect(find.text('Indicadores stub'), findsOneWidget);

    await _pumpAlimentacao(tester);
    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard stub'), findsOneWidget);
  });

  for (final (name, theme) in [
    ('claro', AppTheme.light),
    ('escuro', AppTheme.dark),
  ]) {
    testWidgets('Tela pequena, tema $name: sem overflow e com rolagem', (
      tester,
    ) async {
      await _pumpAlimentacao(tester, size: const Size(320, 568), theme: theme);
      final colors = theme.extension<CareSyncColors>()!;

      // Cores do tema ativo.
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        colors.background,
      );
      expect(_mealIconColor(tester, 'snack'), colors.warning);

      await tester.scrollUntilVisible(
        find.text('Incompleto'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Incompleto'), findsOneWidget);

      // Os círculos da semana diminuem para caber na coluna.
      final circle = tester.getSize(
        find
            .descendant(
              of: find.byType(PlanejamentoSemanalCard),
              matching: find.byType(Container),
            )
            .at(1),
      );
      expect(circle.width, lessThan(40));

      await _tapVisible(tester, find.text('+500ml'));
      await _tapVisible(tester, _confirm('dinner'));

      await tester.tap(find.bySemanticsLabel('Adicionar refeição'));
      await tester.pumpAndSettle();
      expect(find.text('Adicionar Refeição'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Fechar'));
      await tester.pumpAndSettle();

      await _waitToasts(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Tablet: círculos da semana com 40px e sem overflow', (
    tester,
  ) async {
    await _pumpAlimentacao(tester, size: const Size(1024, 1366));

    final dom = find.descendant(
      of: find.byType(PlanejamentoSemanalCard),
      matching: find.text('○'),
    );
    expect(dom, findsNWidgets(3));
    final circle = find.ancestor(
      of: dom.first,
      matching: find.byType(Container),
    );
    expect(tester.getSize(circle.first), const Size(40, 40));
    expect(tester.takeException(), isNull);
  });

  testWidgets('App real: Início → Alimentação mantém o estado ao voltar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: CareSyncApp()));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CareSyncApp)),
    );
    container.read(appRouterProvider).go(RoutePaths.dashboard);
    await tester.pumpAndSettle();

    await _tapVisible(tester, find.text('Alimentação'));
    expect(find.byType(AlimentacaoScreen), findsOneWidget);

    await _tapVisible(tester, _confirm('snack'));
    await _tapVisible(tester, find.text('+300ml'));
    await _waitToasts(tester);

    // O header rola com o conteúdo.
    await _tapVisible(tester, find.bySemanticsLabel('Voltar'));
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(AlimentacaoScreen), findsNothing);

    await _tapVisible(tester, find.text('Alimentação'));
    expect(_confirm('snack'), findsNothing);
    expect(find.text('1500ml / 2000ml'), findsOneWidget);
  });
}
