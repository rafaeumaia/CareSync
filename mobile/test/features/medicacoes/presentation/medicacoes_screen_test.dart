import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/notifications/local_notification_gateway.dart';
import 'package:caresync/core/router/app_router.dart';
import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/core/widgets/app_badge.dart';
import 'package:caresync/core/widgets/app_button.dart';
import 'package:caresync/core/widgets/bottom_nav_shell.dart';
import 'package:caresync/core/widgets/lucide_icon.dart';
import 'package:caresync/features/dashboard/presentation/dashboard_screen.dart';
import 'package:caresync/features/medicacoes/data/medicacao_repository.dart';
import 'package:caresync/features/medicacoes/presentation/medicacoes_screen.dart';
import 'package:caresync/features/medicacoes/presentation/widgets/medicacao_cards.dart';
import 'package:caresync/features/medicacoes/state/medicacoes_providers.dart';
import 'package:caresync/main.dart';

import '../../../helpers/fake_notification_gateway.dart';

Widget _stub(String name) => Scaffold(body: Center(child: Text('$name stub')));

/// Abre a tela e devolve o gateway falso de notificações usado por ela.
Future<FakeNotificationGateway> _pumpMedicacoes(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  ThemeData? theme,
  MedicacaoRepository? repository,
}) async {
  final gateway = FakeNotificationGateway();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localNotificationGatewayProvider.overrideWithValue(gateway),
        if (repository != null)
          medicacaoRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: theme ?? AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: GoRouter(
          initialLocation: RoutePaths.medicacoes,
          routes: [
            GoRoute(
              path: RoutePaths.medicacoes,
              builder: (context, state) => const MedicacoesScreen(),
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
  return gateway;
}

/// Deixa os toasts (4s) terminarem.
Future<void> _waitToasts(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

Finder _markButton(int id) => find.byKey(ValueKey('marcar-tomado-$id'));
Finder _unmarkButton(int id) => find.byKey(ValueKey('desmarcar-tomado-$id'));
Finder _deleteButton(int id) => find.byKey(ValueKey('excluir-medicacao-$id'));

Finder _inCard(int id, Finder finder) => find.descendant(
      of: find.byKey(ValueKey('medicacao-$id')),
      matching: finder,
    );

Color _pillColor(WidgetTester tester, int id) => tester
    .widget<LucideIcon>(_inCard(id, find.byType(LucideIcon)).first)
    .color!;

AppButton _addButton(WidgetTester tester) => tester.widget<AppButton>(
      find.widgetWithText(AppButton, 'Adicionar Medicação'),
    );

/// Lido dentro dos testes: o tema usa `google_fonts`, que exige a binding.
CareSyncColors get _colors => AppTheme.light.extension<CareSyncColors>()!;

void main() {
  testWidgets('Mostra header, medicações do protótipo e card informativo',
      (tester) async {
    await _pumpMedicacoes(tester);

    expect(find.text('Minhas Medicações'), findsOneWidget);
    expect(find.text('Gerencie os medicamentos diários'), findsOneWidget);

    for (final text in [
      'Losartana', '50mg', '08:00',
      'Metformina', '850mg', '14:00', '2x ao dia',
      'Sinvastatina', '20mg', '21:00',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Diariamente'), findsNWidgets(2));

    // Losartana já tomada: badge e pílula verdes, botão de desmarcar.
    expect(_inCard(1, find.byType(AppBadge)), findsOneWidget);
    expect(_markButton(1), findsNothing);
    expect(_unmarkButton(1), findsOneWidget);
    expect(_pillColor(tester, 1), _colors.success);
    // As outras: pílula azul e botão "Marcar como tomado".
    expect(_markButton(2), findsOneWidget);
    expect(_markButton(3), findsOneWidget);
    expect(_pillColor(tester, 2), _colors.primary);

    expect(find.text('Lembre-se'), findsOneWidget);
    expect(find.byType(LembreteInfoCard), findsOneWidget);

    // Cada card tem o botão de excluir.
    for (final id in [1, 2, 3]) {
      expect(_deleteButton(id), findsOneWidget);
    }
  });

  testWidgets('Ao abrir, pede permissão de notificações', (tester) async {
    final gateway = await _pumpMedicacoes(tester);
    expect(gateway.permissionRequests, 1);
  });

  testWidgets('Marcar, desmarcar e marcar de novo, com toasts',
      (tester) async {
    await _pumpMedicacoes(tester);

    void expectNotTaken() {
      expect(_inCard(2, find.byType(AppBadge)), findsNothing);
      expect(_markButton(2), findsOneWidget);
      expect(_unmarkButton(2), findsNothing);
      expect(_pillColor(tester, 2), _colors.primary);
    }

    void expectTaken() {
      expect(_inCard(2, find.byType(AppBadge)), findsOneWidget);
      expect(_markButton(2), findsNothing);
      expect(_unmarkButton(2), findsOneWidget);
      expect(_pillColor(tester, 2), _colors.success);
    }

    expectNotTaken();

    await tester.ensureVisible(_markButton(2));
    await tester.tap(_markButton(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Metformina marcado como tomado!'), findsOneWidget);
    expectTaken();
    // As outras não mudam.
    expect(_markButton(3), findsOneWidget);
    await _waitToasts(tester);
    expect(find.text('Metformina marcado como tomado!'), findsNothing);

    await tester.ensureVisible(_unmarkButton(2));
    await tester.tap(_unmarkButton(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Metformina desmarcado como tomado!'), findsOneWidget);
    expectNotTaken();
    await _waitToasts(tester);

    await tester.ensureVisible(_markButton(2));
    await tester.tap(_markButton(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Metformina marcado como tomado!'), findsOneWidget);
    expectTaken();
    expect(find.byType(MedicacaoCard), findsNWidgets(3));
    await _waitToasts(tester);
  });

  testWidgets('Excluir: Cancelar não faz nada', (tester) async {
    final gateway = await _pumpMedicacoes(tester);
    final cancelledBefore = gateway.cancelled.length;

    await tester.tap(_deleteButton(2));
    await tester.pumpAndSettle();
    expect(find.text('Deseja excluir Metformina?'), findsOneWidget);
    expect(
      find.text(
        'A medicação será removida da lista e os lembretes dela serão '
        'cancelados.',
      ),
      findsOneWidget,
    );

    // Tocar fora não fecha (AlertDialog).
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Deseja excluir Metformina?'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Deseja excluir Metformina?'), findsNothing);
    expect(find.text('Metformina'), findsOneWidget);
    expect(find.byType(MedicacaoCard), findsNWidgets(3));
    expect(gateway.cancelled.length, cancelledBefore);
    expect(gateway.scheduled.containsKey(2), isTrue);
  });

  testWidgets('Excluir: Confirmar remove, cancela o lembrete e mostra toast',
      (tester) async {
    final gateway = await _pumpMedicacoes(tester);
    expect(gateway.scheduled.containsKey(2), isTrue);

    await tester.tap(_deleteButton(2));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Excluir'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Deseja excluir Metformina?'), findsNothing);
    expect(find.text('Metformina'), findsNothing);
    expect(find.byType(MedicacaoCard), findsNWidgets(2));
    expect(find.text('Medicação excluída com sucesso!'), findsOneWidget);
    expect(gateway.scheduled.containsKey(2), isFalse);
    expect(gateway.cancelled.last, 2);
    await _waitToasts(tester);
  });

  testWidgets('Excluir todas mostra o estado vazio', (tester) async {
    await _pumpMedicacoes(tester);
    for (final id in [1, 2, 3]) {
      await tester.ensureVisible(_deleteButton(id));
      await tester.tap(_deleteButton(id));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(AppButton, 'Excluir'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Nenhuma medicação cadastrada'), findsOneWidget);
    await _waitToasts(tester);
  });

  testWidgets('Toasts se empilham e podem ser arrastados para cima',
      (tester) async {
    await _pumpMedicacoes(tester);

    await tester.tap(_markButton(2));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.ensureVisible(_markButton(3));
    await tester.tap(_markButton(3));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Metformina marcado como tomado!'), findsOneWidget);
    expect(find.text('Sinvastatina marcado como tomado!'), findsOneWidget);

    await tester.drag(
      find.text('Sinvastatina marcado como tomado!'),
      const Offset(0, -80),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Sinvastatina marcado como tomado!'), findsNothing);

    await _waitToasts(tester);
  });

  testWidgets('FAB abre "Adicionar Medicação" e adicionar insere na lista',
      (tester) async {
    await _pumpMedicacoes(tester);

    await tester.tap(find.bySemanticsLabel('Adicionar medicação'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Medicação'), findsWidgets);
    expect(find.text('Nome do medicamento'), findsOneWidget);
    expect(find.text('Dosagem'), findsOneWidget);
    expect(find.text('Frequência'), findsOneWidget);
    expect(find.text('Horário'), findsOneWidget);
    // Desabilitado até preencher tudo.
    expect(_addButton(tester).onPressed, isNull);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Aspirina');
    await tester.enterText(fields.at(1), '100mg');
    await tester.pump();
    expect(_addButton(tester).onPressed, isNull);

    await tester.tap(find.text('Selecione a frequência'));
    await tester.pumpAndSettle();
    for (final option in [
      'Diariamente',
      '2x ao dia',
      '3x ao dia',
      'Semanalmente',
      'Quando necessário',
    ]) {
      expect(find.text(option), findsWidgets, reason: option);
    }
    await tester.tap(find.text('3x ao dia'));
    await tester.pumpAndSettle();
    expect(find.text('3x ao dia'), findsOneWidget);
    expect(_addButton(tester).onPressed, isNull);

    await tester.tap(find.text('--:--'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('--:--'), findsNothing);
    expect(_addButton(tester).onPressed, isNotNull);

    await tester.tap(find.widgetWithText(AppButton, 'Adicionar Medicação'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Nome do medicamento'), findsNothing);
    expect(find.text('Medicação adicionada com sucesso!'), findsOneWidget);
    expect(find.text('Aspirina'), findsOneWidget);
    expect(find.text('100mg'), findsOneWidget);
    expect(find.text('3x ao dia'), findsOneWidget);
    expect(find.byType(MedicacaoCard), findsNWidgets(4));
    // Nova medicação entra como não tomada, no fim da lista.
    expect(find.text('Marcar como tomado'), findsNWidgets(3));
    final cards = tester.widgetList<MedicacaoCard>(find.byType(MedicacaoCard));
    expect(cards.last.medicacao.name, 'Aspirina');

    await _waitToasts(tester);

    // O formulário volta vazio.
    await tester.tap(find.bySemanticsLabel('Adicionar medicação'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione a frequência'), findsOneWidget);
    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('Fechar o diálogo mantém o que foi preenchido', (tester) async {
    await _pumpMedicacoes(tester);

    await tester.tap(find.bySemanticsLabel('Adicionar medicação'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Aspirina');
    await tester.tap(find.bySemanticsLabel('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Nome do medicamento'), findsNothing);
    expect(find.byType(MedicacaoCard), findsNWidgets(3));

    await tester.tap(find.bySemanticsLabel('Adicionar medicação'));
    await tester.pumpAndSettle();
    expect(find.text('Aspirina'), findsOneWidget);
  });

  testWidgets('Estado vazio', (tester) async {
    await _pumpMedicacoes(
      tester,
      repository: InMemoryMedicacaoRepository(initial: const []),
    );

    expect(find.text('Nenhuma medicação cadastrada'), findsOneWidget);
    expect(find.byType(MedicacaoCard), findsNothing);
    expect(find.byType(LembreteInfoCard), findsOneWidget);
  });

  testWidgets('Voltar leva ao Início; BottomNav sem aba ativa leva às abas',
      (tester) async {
    await _pumpMedicacoes(tester);

    expect(
      tester.widget<AppBottomNav>(find.byType(AppBottomNav)).currentIndex,
      -1,
    );

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Consultas stub'), findsOneWidget);

    await _pumpMedicacoes(tester);
    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Dashboard stub'), findsOneWidget);
  });

  testWidgets('Tela pequena e tema escuro: sem overflow e com rolagem',
      (tester) async {
    await _pumpMedicacoes(
      tester,
      size: const Size(320, 568),
      theme: AppTheme.dark,
    );

    await tester.scrollUntilVisible(
      find.text('Lembre-se'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lembre-se'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Adicionar medicação'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecione a frequência'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quando necessário'));
    await tester.pumpAndSettle();
    expect(find.text('Quando necessário'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('App real: Dashboard → Medicações → voltar ao Dashboard',
      (tester) async {
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

    await tester.tap(find.text('Medicações'));
    await tester.pumpAndSettle();
    expect(find.byType(MedicacoesScreen), findsOneWidget);
    expect(find.text('Minhas Medicações'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(MedicacoesScreen), findsNothing);
  });
}
