import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/core/notifications/local_notification_gateway.dart';
import 'package:caresync/features/medicacoes/data/medicacao_repository.dart';
import 'package:caresync/features/medicacoes/domain/medicacao.dart';
import 'package:caresync/features/medicacoes/domain/medicacao_reminder.dart';
import 'package:caresync/features/medicacoes/state/medicacoes_providers.dart';

import '../../../helpers/fake_notification_gateway.dart';

void main() {
  late FakeNotificationGateway gateway;
  late ProviderContainer container;

  setUp(() {
    gateway = FakeNotificationGateway();
    container = ProviderContainer(
      overrides: [
        localNotificationGatewayProvider.overrideWithValue(gateway),
        medicacaoRepositoryProvider.overrideWithValue(
          InMemoryMedicacaoRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  MedicacoesNotifier notifier() => container.read(medicacoesProvider.notifier);
  Future<List<Medicacao>> load() => container.read(medicacoesProvider.future);
  List<Medicacao> items() => container.read(medicacoesProvider).value!;

  test('Ao carregar, sincroniza os lembretes das medicações', () async {
    await load();
    await pumpEventQueue();
    expect(gateway.scheduled.keys, unorderedEquals([1, 2, 3]));
  });

  test('Adicionar insere na lista e agenda o lembrete', () async {
    await load();
    await notifier().add(
      const MedicacaoDraft(
        name: 'Aspirina',
        dosage: '100mg',
        frequency: 'Diariamente',
        time: '07:30',
      ),
    );
    final added = items().last;
    expect(added.name, 'Aspirina');
    expect(added.taken, isFalse);
    final reminder = gateway.scheduled[medicacaoNotificationId(added.id)]!;
    expect(reminder.title, 'Hora de tomar Aspirina');
  });

  test('Excluir remove da lista e cancela o lembrete', () async {
    await load();
    await pumpEventQueue();

    final deleted = await notifier().delete(2);

    expect(deleted?.name, 'Metformina');
    expect(items().map((m) => m.id), [1, 3]);
    expect(gateway.scheduled.containsKey(2), isFalse);
    expect(gateway.cancelled.last, 2);
    // Excluir de novo não faz nada.
    expect(await notifier().delete(2), isNull);
  });

  test('Marcar, desmarcar e marcar de novo, sem estados duplicados',
      () async {
    await load();

    expect(await notifier().setTaken(2, taken: true), isTrue);
    expect(items().firstWhere((m) => m.id == 2).taken, isTrue);
    // Repetir não muda nada.
    expect(await notifier().setTaken(2, taken: true), isFalse);

    expect(await notifier().setTaken(2, taken: false), isTrue);
    expect(items().firstWhere((m) => m.id == 2).taken, isFalse);

    expect(await notifier().setTaken(2, taken: true), isTrue);
    expect(items().firstWhere((m) => m.id == 2).taken, isTrue);

    expect(items(), hasLength(3));
    expect(items().where((m) => m.id == 2), hasLength(1));
  });

  test('Toques simultâneos geram uma única alteração', () async {
    await load();
    final results = await Future.wait([
      notifier().setTaken(3, taken: true),
      notifier().setTaken(3, taken: true),
    ]);
    expect(results.where((changed) => changed), hasLength(1));
    expect(items().firstWhere((m) => m.id == 3).taken, isTrue);
  });
}
