import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/features/alimentacao/data/alimentacao_repository.dart';
import 'package:caresync/features/alimentacao/domain/hidratacao.dart';
import 'package:caresync/features/alimentacao/state/alimentacao_providers.dart';

ProviderContainer _container([AlimentacaoRepository? repository]) {
  final container = ProviderContainer(
    overrides: [
      alimentacaoRepositoryProvider.overrideWithValue(
        repository ?? InMemoryAlimentacaoRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('Carrega os dados do protótipo', () async {
    final container = _container();

    final refeicoes = await container.read(refeicoesProvider.future);
    expect(refeicoes.map((r) => r.id), [
      'breakfast',
      'lunch',
      'snack',
      'dinner',
    ]);
    expect(refeicoes.map((r) => r.completed), [true, true, false, false]);

    final hidratacao = await container.read(hidratacaoProvider.future);
    expect(hidratacao.intakeMl, 1200);
    expect(hidratacao.goalMl, 2000);
    expect(hidratacao.percent, 60);

    final semana = await container.read(planejamentoSemanalProvider.future);
    expect(semana.map((d) => d.label), [
      'Seg',
      'Ter',
      'Qua',
      'Qui',
      'Sex',
      'Sáb',
      'Dom',
    ]);
  });

  test('toggle alterna a refeição e grava no repositório', () async {
    final repository = InMemoryAlimentacaoRepository();
    final container = _container(repository);
    await container.read(refeicoesProvider.future);
    final notifier = container.read(refeicoesProvider.notifier);

    final confirmed = await notifier.toggle('snack');
    expect(confirmed!.completed, isTrue);
    expect(
      container
          .read(refeicoesProvider)
          .value!
          .firstWhere((r) => r.id == 'snack')
          .completed,
      isTrue,
    );
    expect(
      (await repository.fetchRefeicoes())
          .firstWhere((r) => r.id == 'snack')
          .completed,
      isTrue,
    );

    final undone = await notifier.toggle('snack');
    expect(undone!.completed, isFalse);

    expect(await notifier.toggle('nao-existe'), isNull);
  });

  test('toggle simultâneo da mesma refeição altera só uma vez', () async {
    final container = _container();
    await container.read(refeicoesProvider.future);
    final notifier = container.read(refeicoesProvider.notifier);

    final results = await Future.wait([
      notifier.toggle('dinner'),
      notifier.toggle('dinner'),
    ]);
    expect(results.whereType<Object>(), hasLength(1));
    expect(
      container
          .read(refeicoesProvider)
          .value!
          .firstWhere((r) => r.id == 'dinner')
          .completed,
      isTrue,
    );
  });

  test('addAgua soma e não passa da meta', () async {
    final container = _container();
    await container.read(hidratacaoProvider.future);
    final notifier = container.read(hidratacaoProvider.notifier);

    await notifier.addAgua(500);
    expect(container.read(hidratacaoProvider).value!.intakeMl, 1700);

    await notifier.addAgua(500);
    final capped = container.read(hidratacaoProvider).value!;
    expect(capped.intakeMl, 2000);
    expect(capped.progress, 1);
    expect(capped.percent, 100);
  });

  test('Hidratacao arredonda o percentual como Math.round', () {
    expect(const Hidratacao(intakeMl: 1, goalMl: 3).percent, 33);
    expect(const Hidratacao(intakeMl: 2, goalMl: 3).percent, 67);
    expect(const Hidratacao(intakeMl: 0, goalMl: 0).progress, 0);
  });
}
