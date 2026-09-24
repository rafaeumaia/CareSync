import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/core/utils/date_formatters.dart';
import 'package:caresync/core/widgets/app_header.dart';
import 'package:caresync/core/widgets/bottom_nav_shell.dart';
import 'package:caresync/features/dashboard/presentation/dashboard_screen.dart';
import 'package:caresync/features/dashboard/presentation/widgets/dashboard_widgets.dart';
import 'package:caresync/features/dashboard/state/dashboard_providers.dart';

Widget _stub(String name) => Scaffold(body: Center(child: Text('$name stub')));

GoRouter _buildRouter() => GoRouter(
      initialLocation: RoutePaths.dashboard,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              BottomNavShell(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.consultas,
                builder: (context, state) => _stub('Consultas'),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.indicadores,
                builder: (context, state) => _stub('Indicadores'),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: RoutePaths.relatorios,
                builder: (context, state) => _stub('Relatórios'),
              ),
            ]),
          ],
        ),
        GoRoute(
          path: RoutePaths.medicacoes,
          builder: (context, state) => _stub('Medicações'),
        ),
        GoRoute(
          path: RoutePaths.alimentacao,
          builder: (context, state) => _stub('Alimentação'),
        ),
        GoRoute(
          path: RoutePaths.perfil,
          builder: (context, state) => _stub('Perfil'),
        ),
      ],
    );

Future<void> _pumpDashboard(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        todayProvider.overrideWithValue(DateTime(2025, 10, 27)),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: _buildRouter(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Mostra header, data, cards, tarefas e ações do protótipo',
      (tester) async {
    await _pumpDashboard(tester);

    for (final text in [
      'Olá, Gustavo Werneck 👋',
      'GW',
      'Segunda-feira, 27 de Outubro',
      'Próxima em',
      '2 dias',
      'Medicações',
      '3 hoje',
      'Tarefas do Dia',
      'Losartana 50mg',
      '14:00',
      'Consulta – Dr. Silva',
      '15:30',
      'Medir pressão',
      'Manhã',
      'Indicadores',
      'Alimentação',
      'Relatórios',
      'Início',
      'Agenda',
      'Saúde',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }

    // Só a tarefa concluída tem o badge ✓ e o título riscado.
    expect(find.byKey(const ValueKey('task-done-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-done-2')), findsNothing);
    final doneTitle = tester.widget<Text>(find.text('Losartana 50mg'));
    expect(doneTitle.style!.decoration, TextDecoration.lineThrough);

    // 3 notificações -> ponto vermelho no sino.
    expect(find.byKey(const ValueKey('notification-dot')), findsOneWidget);
  });

  testWidgets('Início é a aba ativa do BottomNav', (tester) async {
    await _pumpDashboard(tester);

    final context = tester.element(find.byType(DashboardScreen));
    final colors = context.careSyncColors;
    final nav = find.byType(AppBottomNav);
    Color labelColor(String label) => tester
        .widget<Text>(find.descendant(of: nav, matching: find.text(label)))
        .style!
        .color!;

    expect(tester.widget<AppBottomNav>(nav).currentIndex, 0);
    expect(labelColor('Início'), colors.primary);
    expect(labelColor('Agenda'), colors.mutedForeground);
  });

  testWidgets('BottomNav alterna entre as abas e volta ao Início',
      (tester) async {
    await _pumpDashboard(tester);
    final nav = find.byType(AppBottomNav);

    for (final (label, stub) in [
      ('Agenda', 'Consultas stub'),
      ('Saúde', 'Indicadores stub'),
      ('Relatórios', 'Relatórios stub'),
    ]) {
      await tester
          .tap(find.descendant(of: nav, matching: find.text(label)));
      await tester.pumpAndSettle();
      expect(find.text(stub), findsOneWidget, reason: label);
    }

    await tester.tap(find.descendant(of: nav, matching: find.text('Início')));
    await tester.pumpAndSettle();
    expect(find.text('Tarefas do Dia'), findsOneWidget);
  });

  for (final (target, stub) in [
    ('Próxima em', 'Consultas stub'),
    ('3 hoje', 'Medicações stub'),
    ('Indicadores', 'Indicadores stub'),
    ('Alimentação', 'Alimentação stub'),
  ]) {
    testWidgets('"$target" navega para $stub', (tester) async {
      await _pumpDashboard(tester);
      await _tapAndSettle(tester, find.text(target));
      expect(find.text(stub), findsOneWidget);
    });
  }

  testWidgets('Ação rápida "Relatórios" navega para Relatórios',
      (tester) async {
    await _pumpDashboard(tester);
    final quickAction = find
        .ancestor(
          of: find.text('Relatórios'),
          matching: find.byType(QuickActionButton),
        )
        .first;
    await _tapAndSettle(tester, quickAction);
    expect(find.text('Relatórios stub'), findsOneWidget);
  });

  testWidgets('Avatar navega para o Perfil e voltar retorna ao Início',
      (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.byKey(const ValueKey('header-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Perfil stub'), findsOneWidget);

    final router = GoRouter.of(tester.element(find.text('Perfil stub')));
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Tarefas do Dia'), findsOneWidget);
  });

  testWidgets('FAB (+) navega para Consultas', (tester) async {
    await _pumpDashboard(tester);

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    expect(find.text('Consultas stub'), findsOneWidget);
  });

  testWidgets('Tela pequena: sem overflow e com rolagem até o fim',
      (tester) async {
    await _pumpDashboard(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Alimentação'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('Iniciais e data por extenso seguem o protótipo', () {
    expect(initialsOf('Gustavo Werneck'), 'GW');
    expect(initialsOf('Ana'), 'A');
    expect(initialsOf('maria da silva'), 'MS');
    expect(formatWeekdayDayMonth(DateTime(2025, 10, 27)),
        'Segunda-feira, 27 de Outubro');
    expect(formatWeekdayDayMonth(DateTime(2026, 3, 1)), 'Domingo, 1 de Março');
  });
}
