import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:caresync/core/router/route_paths.dart';
import 'package:caresync/core/session/current_user.dart';
import 'package:caresync/core/theme/app_colors.dart';
import 'package:caresync/core/theme/app_theme.dart';
import 'package:caresync/features/consultas/data/consulta_repository.dart';
import 'package:caresync/features/consultas/domain/consulta.dart';
import 'package:caresync/features/consultas/presentation/consultas_screen.dart';
import 'package:caresync/features/consultas/presentation/widgets/consulta_cards.dart';

Future<void> _pumpConsultas(
  WidgetTester tester, {
  required DateTime today,
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [currentDateProvider.overrideWithValue(today)],
      child: MaterialApp.router(
        theme: theme ?? AppTheme.light,
        // Mesmo locale do app (seletores em pt-BR, relógio de 24h).
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: GoRouter(
          initialLocation: RoutePaths.consultas,
          routes: [
            GoRoute(
              path: RoutePaths.consultas,
              builder: (context, state) =>
                  const Scaffold(body: ConsultasScreen()),
            ),
            GoRoute(
              path: RoutePaths.perfil,
              builder: (context, state) =>
                  const Scaffold(body: Text('Perfil stub')),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Finder _dialogField(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextField),
);

void main() {
  testWidgets('Abas Próximas/Passadas separam os mocks pela data de hoje', (
    tester,
  ) async {
    // Entre as duas consultas do protótipo (25/10 e 28/10/2025).
    await _pumpConsultas(tester, today: DateTime(2025, 10, 26));

    expect(find.text('Próximas'), findsOneWidget);
    expect(find.text('Passadas'), findsOneWidget);
    expect(find.text('Dra. Maria Santos'), findsOneWidget);
    expect(find.text('Geriatria'), findsOneWidget);
    expect(find.text('28/10/2025 às 10:00'), findsOneWidget);
    expect(find.text('Hospital Central - 3º andar'), findsOneWidget);
    expect(find.text('Dr. Carlos Silva'), findsNothing);

    await _openTab(tester, 'Passadas');
    expect(find.text('Dr. Carlos Silva'), findsOneWidget);
    expect(find.text('25/10/2025 às 15:30'), findsOneWidget);
    expect(find.byType(PastConsultaCard), findsOneWidget);
    // Cards passados não têm ações.
    expect(find.bySemanticsLabel('Excluir consulta'), findsNothing);
    expect(find.text('Dra. Maria Santos'), findsNothing);
  });

  testWidgets('Consulta do próprio dia continua em Próximas, com observação', (
    tester,
  ) async {
    await _pumpConsultas(tester, today: DateTime(2025, 10, 25));

    expect(find.text('Dr. Carlos Silva'), findsOneWidget);
    expect(find.text('Cardiologia'), findsOneWidget);
    expect(find.text('25/10/2025 às 15:30'), findsOneWidget);
    expect(find.text('Clínica Saúde Total - Sala 203'), findsOneWidget);
    expect(find.text('💡 Levar exames anteriores'), findsOneWidget);
    expect(find.byType(UpcomingConsultaCard), findsNWidgets(2));
  });

  testWidgets('Estados vazios das duas abas', (tester) async {
    // Depois das duas consultas do protótipo.
    await _pumpConsultas(tester, today: DateTime(2026, 9, 24));
    expect(find.text('Nenhuma consulta agendada'), findsOneWidget);

    await _openTab(tester, 'Passadas');
    expect(find.byType(PastConsultaCard), findsNWidgets(2));

    // Antes das duas: nenhuma passada.
    await _pumpConsultas(tester, today: DateTime(2025, 1, 1));
    await _openTab(tester, 'Passadas');
    expect(find.text('Nenhuma consulta passada'), findsOneWidget);
  });

  testWidgets('Abas no tema escuro seguem o protótipo', (tester) async {
    await _pumpConsultas(
      tester,
      today: DateTime(2025, 10, 26),
      theme: AppTheme.dark,
    );
    final colors = AppTheme.dark.extension<CareSyncColors>()!;

    Color textColor(String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;
    BoxDecoration tabDecoration(String label) =>
        tester
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.text(label),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;

    // Ativa: `text-foreground`, fundo `input/30` e borda `input`.
    expect(textColor('Próximas'), colors.foreground);
    expect(
      tabDecoration('Próximas').border!.top.color,
      const Color(0x1AFFFFFF),
    );
    // Inativa: `text-muted-foreground`, sem fundo.
    expect(textColor('Passadas'), colors.mutedForeground);
    expect(tabDecoration('Passadas').color, isNull);
  });

  testWidgets('Excluir remove a consulta da lista', (tester) async {
    await _pumpConsultas(tester, today: DateTime(2025, 10, 26));

    await tester.tap(find.byKey(const ValueKey('delete-consulta-2')));
    await tester.pumpAndSettle();

    expect(find.text('Dra. Maria Santos'), findsNothing);
    expect(find.text('Nenhuma consulta agendada'), findsOneWidget);
  });

  testWidgets('Editar não tem ação (como no protótipo)', (tester) async {
    await _pumpConsultas(tester, today: DateTime(2025, 10, 26));

    await tester.tap(find.bySemanticsLabel('Editar consulta'));
    await tester.pumpAndSettle();

    expect(find.text('Dra. Maria Santos'), findsOneWidget);
    expect(find.text('Nova Consulta'), findsNothing);
  });

  testWidgets('FAB abre "Nova Consulta" e adicionar insere na lista', (
    tester,
  ) async {
    await _pumpConsultas(tester, today: DateTime(2026, 9, 24));
    expect(find.text('Nenhuma consulta agendada'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Consulta'), findsOneWidget);
    for (final text in [
      'Médico',
      'Especialidade',
      'Data',
      'Horário',
      'Local',
      'Observações',
      'Nome do médico',
      'Ex: Cardiologia',
      'dd/mm/aaaa',
      '--:--',
      'Clínica ou hospital',
      'Informações adicionais...',
      'Adicionar Consulta',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.enterText(_dialogField('Médico'), 'Dr. João Lima');
    await tester.enterText(_dialogField('Especialidade'), 'Neurologia');
    await tester.enterText(_dialogField('Local'), 'Clínica Norte');
    await tester.enterText(_dialogField('Observações'), 'Em jejum');

    // Data: o seletor abre em hoje (24/09/2026); confirma.
    await tester.tap(find.text('dd/mm/aaaa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('24/09/2026'), findsOneWidget);

    // Horário: confirma o horário sugerido pelo seletor.
    await tester.tap(find.text('--:--'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('--:--'), findsNothing);

    await tester.ensureVisible(find.text('Adicionar Consulta'));
    await tester.tap(find.text('Adicionar Consulta'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Consulta'), findsNothing);
    expect(find.text('Dr. João Lima'), findsOneWidget);
    expect(find.text('Neurologia'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            RegExp(r'^24/09/2026 às \d{2}:\d{2}$').hasMatch(w.data ?? ''),
      ),
      findsOneWidget,
    );
    expect(find.text('Clínica Norte'), findsOneWidget);
    expect(find.text('💡 Em jejum'), findsOneWidget);

    // O formulário volta limpo na próxima abertura.
    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    expect(find.text('dd/mm/aaaa'), findsOneWidget);
    expect(find.text('Dr. João Lima'), findsOneWidget); // só o card
  });

  testWidgets('Sem data, "Adicionar Consulta" abre o seletor de data', (
    tester,
  ) async {
    await _pumpConsultas(tester, today: DateTime(2026, 9, 24));

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    await tester.enterText(_dialogField('Médico'), 'Dr. Sem Data');
    await tester.ensureVisible(find.text('Adicionar Consulta'));
    await tester.tap(find.text('Adicionar Consulta'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Consulta'), findsOneWidget);
  });

  testWidgets('Fechar o diálogo mantém o que foi digitado', (tester) async {
    await _pumpConsultas(tester, today: DateTime(2026, 9, 24));

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    await tester.enterText(_dialogField('Médico'), 'Dra. Ana');

    await tester.tap(find.bySemanticsLabel('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Nova Consulta'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    expect(find.text('Dra. Ana'), findsOneWidget);
  });

  testWidgets('Tela pequena: lista e diálogo sem overflow', (tester) async {
    await _pumpConsultas(
      tester,
      today: DateTime(2025, 10, 25),
      size: const Size(320, 568),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Nova consulta'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('isUpcoming compara apenas o dia', () {
    final c = InMemoryConsultaRepository.seed.first; // 25/10/2025
    expect(c.isUpcoming(DateTime(2025, 10, 24)), isTrue);
    expect(c.isUpcoming(DateTime(2025, 10, 25, 23, 59)), isTrue);
    expect(c.isUpcoming(DateTime(2025, 10, 26)), isFalse);
  });

  test('Repositório em memória adiciona e remove', () async {
    final repo = InMemoryConsultaRepository();
    expect(await repo.fetchAll(), hasLength(2));
    final added = await repo.add(
      ConsultaDraft(
        doctor: 'A',
        specialty: 'B',
        date: DateTime(2026, 1, 1),
        time: '',
        location: 'C',
        notes: '',
      ),
    );
    expect(added.notes, isNull);
    expect(await repo.fetchAll(), hasLength(3));
    await repo.delete(added.id);
    expect(await repo.fetchAll(), hasLength(2));
  });
}
