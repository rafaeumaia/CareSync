import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/app_router.dart';
import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/session/current_user.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/core/widgets/app_button.dart';
import 'package:caresync/core/widgets/app_segmented_tabs.dart';
import 'package:caresync/core/widgets/app_text_field.dart';
import 'package:caresync/core/widgets/bottom_nav_shell.dart';
import 'package:caresync/features/dashboard/presentation/dashboard_screen.dart';
import 'package:caresync/features/indicadores/data/indicadores_repository.dart';
import 'package:caresync/features/indicadores/domain/indicador.dart';
import 'package:caresync/features/indicadores/presentation/indicadores_screen.dart';
import 'package:caresync/features/indicadores/presentation/widgets/health_line_chart.dart';
import 'package:caresync/features/indicadores/presentation/widgets/indicator_card.dart';
import 'package:caresync/features/indicadores/presentation/widgets/indicator_chart_card.dart';
import 'package:caresync/features/indicadores/state/indicadores_providers.dart';
import 'package:caresync/main.dart';

/// Quinta-feira, 22/10/2026, 10:00.
final _today = DateTime(2026, 10, 22);
final _now = DateTime(2026, 10, 22, 10);

Future<ProviderContainer> _pumpIndicadores(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  ThemeData? theme,
  List<IndicatorRecord>? records,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentDateProvider.overrideWithValue(_today),
        clockProvider.overrideWithValue(() => _now),
        indicadoresRepositoryProvider.overrideWithValue(
          InMemoryIndicadoresRepository(today: _today, initial: records),
        ),
      ],
      child: MaterialApp.router(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: GoRouter(
          initialLocation: RoutePaths.indicadores,
          routes: [
            GoRoute(
              path: RoutePaths.indicadores,
              builder: (context, state) =>
                  const Scaffold(body: IndicadoresScreen()),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(
    tester.element(find.byType(IndicadoresScreen)),
  );
}

/// Deixa os toasts (4s) terminarem.
Future<void> _waitToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Finder _chart(IndicatorType type) =>
    find.byKey(ValueKey('grafico-${type.name}'));

Finder _inChart(IndicatorType type, String text) =>
    find.descendant(of: _chart(type), matching: find.text(text));

LineChartData _chartData(WidgetTester tester, IndicatorType type) => tester
    .widget<LineChart>(
      find.descendant(of: _chart(type), matching: find.byType(LineChart)),
    )
    .data;

List<double> _ys(LineChartBarData bar) => [for (final s in bar.spots) s.y];

String _cardValue(WidgetTester tester, IndicatorType type) {
  final card = find.byWidgetPredicate(
    (w) => w is IndicatorCard && w.type == type,
  );
  return tester.widget<IndicatorCard>(card).latest!.formattedValue;
}

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Adicionar indicador'));
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, IndicatorType type) async {
  await tester.tap(find.text(type.label).last);
  await tester.pumpAndSettle();
}

/// Escolhe a data e hora atuais (relógio fixo) nos seletores.
Future<void> _pickNow(WidgetTester tester) async {
  final field = find.text('dd/mm/aaaa --:--');
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> _submit(WidgetTester tester) async {
  final button = find.widgetWithText(AppButton, 'Adicionar Registro');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _selectPeriod(WidgetTester tester, String label) async {
  final tabs = find.byType(AppSegmentedTabs);
  await tester.ensureVisible(tabs);
  await tester.tap(find.descendant(of: tabs, matching: find.text(label)));
  await tester.pumpAndSettle();
}

/// Lido dentro dos testes: o tema usa `google_fonts`, que exige a binding.
CareSyncColors get _light => AppTheme.light.extension<CareSyncColors>()!;

void main() {
  testWidgets('Cards com os valores do protótipo e cores semânticas', (
    tester,
  ) async {
    await _pumpIndicadores(tester);

    expect(find.text('Olá, Gustavo Werneck 👋'), findsOneWidget);
    expect(_cardValue(tester, IndicatorType.pressure), '126/80');
    expect(_cardValue(tester, IndicatorType.glucose), '109');
    expect(_cardValue(tester, IndicatorType.temperature), '36.5');
    expect(_cardValue(tester, IndicatorType.weight), '72.5');
    for (final t in IndicatorType.values) {
      expect(find.text(t.unit), findsOneWidget, reason: t.unit);
    }

    Color valueColor(String value) => tester
        .widget<Text>(
          find.descendant(
            of: find.byType(IndicatorCard),
            matching: find.text(value),
          ),
        )
        .style!
        .color!;
    expect(valueColor('126/80'), _light.destructive);
    expect(valueColor('109'), _light.primary);
    expect(valueColor('36.5'), _light.warning);
    expect(valueColor('72.5'), _light.success);
  });

  testWidgets('Grade 2x2 com cards da mesma largura', (tester) async {
    await _pumpIndicadores(tester);
    final cards = find.byType(IndicatorCard);
    expect(cards, findsNWidgets(4));
    final rects = [for (var i = 0; i < 4; i++) tester.getRect(cards.at(i))];
    expect(rects[0].top, rects[1].top);
    expect(rects[0].width, rects[1].width);
    expect(rects[1].left - rects[0].right, 16);
    expect(rects[2].top - rects[0].bottom, 16);
  });

  testWidgets('Gráficos para os 4 indicadores, com o período no título', (
    tester,
  ) async {
    await _pumpIndicadores(tester);
    for (final t in IndicatorType.values) {
      expect(find.text('${t.label} (7 dias)'), findsOneWidget, reason: t.label);
    }
    expect(find.byType(IndicatorChartCard), findsNWidgets(4));
    // Só a pressão tem legenda, como no protótipo.
    expect(find.byType(ChartLegend), findsOneWidget);
  });

  testWidgets('Gráfico de pressão: dados, cores, dias e eixo Y dinâmico', (
    tester,
  ) async {
    await _pumpIndicadores(tester);
    final data = _chartData(tester, IndicatorType.pressure);

    expect(_ys(data.lineBarsData[0]), [130, 125, 128, 132, 127, 129, 126]);
    expect(_ys(data.lineBarsData[1]), [85, 80, 82, 86, 81, 83, 80]);
    expect(data.lineBarsData[0].color, _light.destructive);
    expect(data.lineBarsData[1].color, _light.primary);

    // Eixo Y ajustado: de 60 a 140 (antes, de 0 a 140).
    expect((data.minY, data.maxY), (60.0, 140.0));
    expect(data.titlesData.leftTitles.sideTitles.interval, 20);
    for (final tick in ['60', '80', '100', '120', '140']) {
      expect(
        _inChart(IndicatorType.pressure, tick),
        findsOneWidget,
        reason: tick,
      );
    }

    // De sexta (16/10) a quinta (22/10).
    for (final day in ['Sex', 'Sáb', 'Dom', 'Seg', 'Ter', 'Qua', 'Qui']) {
      expect(
        _inChart(IndicatorType.pressure, day),
        findsOneWidget,
        reason: day,
      );
    }
  });

  testWidgets('Eixo Y dinâmico em glicemia, temperatura e peso', (
    tester,
  ) async {
    await _pumpIndicadores(tester);

    for (final (type, min, max) in [
      (IndicatorType.glucose, 100.0, 120.0),
      (IndicatorType.temperature, 35.0, 38.0),
      (IndicatorType.weight, 70.0, 76.0),
    ]) {
      await tester.ensureVisible(_chart(type));
      final data = _chartData(tester, type);
      expect((data.minY, data.maxY), (min, max), reason: type.label);
      // Nenhum ponto cortado.
      for (final s in data.lineBarsData.single.spots) {
        expect(s.y, inExclusiveRange(min, max), reason: type.label);
      }
    }

    // Uma medição só (temperatura): um ponto no meio do eixo X.
    final temperature = _chartData(tester, IndicatorType.temperature);
    final spot = temperature.lineBarsData.single.spots.single;
    expect(spot.y, 36.5);
    expect(spot.x, (temperature.minX + temperature.maxX) / 2);
  });

  testWidgets('Períodos de 7, 30 e 90 dias filtram os gráficos', (
    tester,
  ) async {
    await _pumpIndicadores(
      tester,
      records: [
        ...InMemoryIndicadoresRepository.seed(_today),
        // 20 dias atrás: aparece em 30 e 90 dias.
        IndicatorRecord(
          id: 100,
          type: IndicatorType.glucose,
          recordedAt: DateTime(2026, 10, 2, 8),
          value: 130,
        ),
        // 60 dias atrás: só em 90 dias.
        IndicatorRecord(
          id: 101,
          type: IndicatorType.glucose,
          recordedAt: DateTime(2026, 8, 23, 8),
          value: 95,
        ),
      ],
    );

    expect(_ys(_chartData(tester, IndicatorType.glucose).lineBarsData.single), [
      110,
      105,
      115,
      108,
      112,
      107,
      109,
    ]);

    await _selectPeriod(tester, '30 dias');
    expect(find.text('Glicemia (30 dias)'), findsOneWidget);
    var data = _chartData(tester, IndicatorType.glucose);
    expect(data.lineBarsData.single.spots, hasLength(8));
    expect(_ys(data.lineBarsData.single).first, 130);
    // Eixo X em `dd/mm` e eixo Y reajustado para incluir o 130.
    expect(_inChart(IndicatorType.glucose, '02/10'), findsOneWidget);
    expect(data.maxY, greaterThan(130));

    await _selectPeriod(tester, '90 dias');
    data = _chartData(tester, IndicatorType.glucose);
    expect(data.lineBarsData.single.spots, hasLength(9));
    expect(_ys(data.lineBarsData.single).take(2), [95, 130]);
    expect(data.minY, lessThan(95));

    await _selectPeriod(tester, '7 dias');
    expect(
      _chartData(tester, IndicatorType.glucose).lineBarsData.single.spots,
      hasLength(7),
    );
  });

  testWidgets('Muitas medições: rótulos do eixo X espaçados', (tester) async {
    await _pumpIndicadores(
      tester,
      records: [
        for (var i = 0; i < 30; i++)
          IndicatorRecord(
            id: i + 1,
            type: IndicatorType.weight,
            recordedAt: DateTime(2026, 10, 22 - i, 8),
            value: 70 + i / 10,
          ),
      ],
    );
    await _selectPeriod(tester, '30 dias');
    final data = _chartData(tester, IndicatorType.weight);
    expect(data.lineBarsData.single.spots, hasLength(30));
    expect(
      data.titlesData.bottomTitles.sideTitles.interval,
      HealthLineChart.labelInterval(30),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sem medições: "--" nos cards e aviso nos gráficos', (
    tester,
  ) async {
    await _pumpIndicadores(tester, records: const []);
    expect(find.text('--'), findsNWidgets(4));
    for (final t in IndicatorType.values) {
      await tester.ensureVisible(
        find.byKey(ValueKey('card-grafico-${t.name}')),
      );
    }
    expect(find.text('Nenhum registro no período'), findsNWidgets(4));
  });

  testWidgets('Tooltip: data e "Nome : valor" na cor de cada linha', (
    tester,
  ) async {
    await _pumpIndicadores(tester);
    final data = _chartData(tester, IndicatorType.pressure);
    final tooltip = data.lineTouchData.touchTooltipData;
    final spots = [
      for (var i = 0; i < 2; i++)
        LineBarSpot(data.lineBarsData[i], i, data.lineBarsData[i].spots[6]),
    ];
    final first = tooltip.getTooltipItems(spots).first!;
    expect(first.text, '22/10 08:00');
    expect(
      [for (final c in first.children!) c.toPlainText()],
      ['\nSistólica : 126', '\nDiastólica : 80'],
    );
    expect(first.children![0].style!.color, _light.destructive);
    expect(tooltip.tooltipBorder.color, const Color(0xFFCCCCCC));

    final rect = tester.getRect(_chart(IndicatorType.pressure));
    final gesture = await tester.startGesture(rect.center);
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('Adicionar Indicador', () {
    testWidgets('Formulário vazio: erros e o diálogo continua aberto', (
      tester,
    ) async {
      final container = await _pumpIndicadores(tester);
      final before = container.read(indicadoresProvider).value!.length;
      await _openDialog(tester);
      await _choose(tester, IndicatorType.glucose);
      await _submit(tester);

      expect(find.text('Adicionar Indicador'), findsOneWidget);
      expect(find.text('Informe o valor.'), findsOneWidget);
      expect(find.text('Informe a data e hora.'), findsOneWidget);
      expect(find.text('Indicador registrado com sucesso!'), findsNothing);
      expect(container.read(indicadoresProvider).value!, hasLength(before));

      // Label e mensagem em `destructive`.
      final label = tester.widget<Text>(
        find.descendant(
          of: find.byType(AppFieldLabel),
          matching: find.text('Valor'),
        ),
      );
      expect(label.style!.color, _light.destructive);
      expect(
        tester.widget<Text>(find.text('Informe o valor.')).style!.color,
        _light.destructive,
      );

      // Corrigir o campo apaga o erro dele.
      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();
      expect(find.text('Informe o valor.'), findsNothing);
      expect(find.text('Informe a data e hora.'), findsOneWidget);
    });

    testWidgets('Valores inválidos não são salvos', (tester) async {
      final container = await _pumpIndicadores(tester);
      final before = container.read(indicadoresProvider).value!.length;
      await _openDialog(tester);
      await _choose(tester, IndicatorType.weight);
      await _pickNow(tester);

      for (final (text, message) in [
        ('abc', 'Digite um número válido.'),
        ('-3', 'Digite um número válido.'),
        ('7..2', 'Digite um número válido.'),
        ('0', 'O valor deve ser maior que zero.'),
      ]) {
        await tester.enterText(find.byType(TextField), text);
        await _submit(tester);
        expect(find.text(message), findsOneWidget, reason: text);
        expect(find.text('Adicionar Indicador'), findsOneWidget);
      }
      expect(container.read(indicadoresProvider).value!, hasLength(before));
    });

    testWidgets('Pressão: sistólica e diastólica validadas separadamente', (
      tester,
    ) async {
      await _pumpIndicadores(tester);
      await _openDialog(tester);
      await _choose(tester, IndicatorType.pressure);

      Finder label(String text) => find.descendant(
        of: find.byType(AppFieldLabel),
        matching: find.text(text),
      );
      expect(label('Sistólica'), findsOneWidget);
      expect(label('Diastólica'), findsOneWidget);
      expect(label('Valor'), findsNothing);

      await _submit(tester);
      expect(find.text('Informe a sistólica.'), findsOneWidget);
      expect(find.text('Informe a diastólica.'), findsOneWidget);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '80');
      await tester.enterText(fields.at(1), '120');
      await _pickNow(tester);
      await _submit(tester);
      expect(
        find.text('A diastólica deve ser menor que a sistólica.'),
        findsOneWidget,
      );
      expect(find.text('Informe a sistólica.'), findsNothing);
      expect(find.text('Adicionar Indicador'), findsOneWidget);
    });

    Future<void> register(
      WidgetTester tester,
      IndicatorType type,
      List<String> values,
    ) async {
      await _openDialog(tester);
      await _choose(tester, type);
      final fields = find.byType(TextField);
      for (var i = 0; i < values.length; i++) {
        await tester.enterText(fields.at(i), values[i]);
      }
      await _pickNow(tester);
      await _submit(tester);
    }

    testWidgets('Cadastro de cada tipo atualiza card e gráfico', (
      tester,
    ) async {
      final container = await _pumpIndicadores(tester);

      for (final (type, values, card, ys) in [
        (IndicatorType.pressure, ['140', '90'], '140/90', [140.0, 90.0]),
        (IndicatorType.glucose, ['120'], '120', [120.0]),
        (IndicatorType.temperature, ['37,2'], '37.2', [37.2]),
        (IndicatorType.weight, ['70'], '70', [70.0]),
      ]) {
        await register(tester, type, values);

        // Fecha, mostra o toast e atualiza card e gráfico na hora.
        expect(
          find.text('Adicionar Indicador'),
          findsNothing,
          reason: type.label,
        );
        expect(find.text('Indicador registrado com sucesso!'), findsOneWidget);
        expect(_cardValue(tester, type), card, reason: type.label);

        final saved = container.read(indicadoresProvider).value!.last;
        expect(saved.type, type);
        expect(saved.recordedAt, _now);
        expect(saved.value, ys.first);
        expect(saved.diastolic, ys.length > 1 ? ys[1] : null);

        await tester.ensureVisible(_chart(type));
        final data = _chartData(tester, type);
        for (var i = 0; i < ys.length; i++) {
          expect(data.lineBarsData[i].spots.last.y, ys[i], reason: type.label);
          expect(ys[i], inExclusiveRange(data.minY, data.maxY));
        }
        await _waitToasts(tester);
      }

      expect(
        _chartData(tester, IndicatorType.pressure).lineBarsData[0].spots,
        hasLength(8),
      );
      expect(
        _chartData(tester, IndicatorType.temperature).lineBarsData.single.spots,
        hasLength(2),
      );
    });

    testWidgets('Depois de salvar, os campos voltam vazios', (tester) async {
      await _pumpIndicadores(tester);
      await register(tester, IndicatorType.glucose, ['118']);
      await _waitToasts(tester);

      await _openDialog(tester);
      // A escolha continua marcada (protótipo) e os campos estão limpos.
      expect(find.text('Valor'), findsOneWidget);
      expect(find.text('Digite o valor'), findsOneWidget);
      expect(find.text('dd/mm/aaaa --:--'), findsOneWidget);
    });

    testWidgets('Medição mais antiga entra no gráfico sem mudar o card', (
      tester,
    ) async {
      final container = await _pumpIndicadores(tester);
      await container
          .read(indicadoresProvider.notifier)
          .add(
            IndicatorRecordDraft(
              type: IndicatorType.glucose,
              recordedAt: DateTime(2026, 10, 18, 7),
              value: 99,
            ),
          );
      await tester.pumpAndSettle();
      expect(_cardValue(tester, IndicatorType.glucose), '109');
      expect(
        _ys(_chartData(tester, IndicatorType.glucose).lineBarsData.single),
        contains(99),
      );
    });
  });

  testWidgets('"Gerar Relatório Completo (PDF)" continua só com o toast', (
    tester,
  ) async {
    await _pumpIndicadores(tester);
    final button = find.widgetWithText(
      AppButton,
      'Gerar Relatório Completo (PDF)',
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Relatório gerado com sucesso!'), findsOneWidget);
    await _waitToasts(tester);
  });

  testWidgets('Tema escuro e tela pequena: sem overflow e com rolagem', (
    tester,
  ) async {
    await _pumpIndicadores(
      tester,
      size: const Size(320, 568),
      theme: AppTheme.dark,
    );
    final dark = AppTheme.dark.extension<CareSyncColors>()!;

    expect(
      _chartData(
        tester,
        IndicatorType.pressure,
      ).gridData.getDrawingHorizontalLine(80).color,
      dark.border,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byType(IndicatorCard),
              matching: find.text('109'),
            ),
          )
          .style!
          .color,
      dark.primary,
    );
    await _selectPeriod(tester, '90 dias');

    final button = find.text('Gerar Relatório Completo (PDF)');
    await tester.scrollUntilVisible(
      button,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(button, findsOneWidget);

    await _openDialog(tester);
    await _choose(tester, IndicatorType.pressure);
    await _submit(tester);
    expect(
      tester.widget<Text>(find.text('Informe a sistólica.')).style!.color,
      dark.destructive,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('App real: Dashboard → Saúde e ação rápida Indicadores', (
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
    expect(find.byType(DashboardScreen), findsOneWidget);

    final nav = find.byType(AppBottomNav);
    await tester.tap(find.descendant(of: nav, matching: find.text('Saúde')));
    await tester.pumpAndSettle();
    expect(find.byType(IndicadoresScreen), findsOneWidget);
    expect(tester.widget<AppBottomNav>(nav).currentIndex, 2);
    expect(find.byType(IndicatorChartCard), findsNWidgets(4));

    await tester.tap(find.descendant(of: nav, matching: find.text('Início')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Indicadores'));
    await tester.tap(find.text('Indicadores'));
    await tester.pumpAndSettle();
    expect(find.byType(IndicadoresScreen), findsOneWidget);
  });
}
