import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/consulta_repository.dart';
import '../domain/consulta.dart';

/// Repositório de consultas. Trocar pela implementação HTTP quando a API
/// Django existir.
final consultaRepositoryProvider = Provider<ConsultaRepository>(
  (ref) => InMemoryConsultaRepository(),
);

/// Lista de consultas, na ordem de cadastro (o protótipo não ordena).
final consultasProvider =
    AsyncNotifierProvider<ConsultasNotifier, List<Consulta>>(
  ConsultasNotifier.new,
);

class ConsultasNotifier extends AsyncNotifier<List<Consulta>> {
  ConsultaRepository get _repository => ref.read(consultaRepositoryProvider);

  @override
  Future<List<Consulta>> build() =>
      ref.watch(consultaRepositoryProvider).fetchAll();

  Future<void> add(ConsultaDraft draft) async {
    final consulta = await _repository.add(draft);
    state = AsyncData([...?state.value, consulta]);
  }

  Future<void> delete(int id) async {
    await _repository.delete(id);
    state = AsyncData([
      for (final c in state.value ?? const <Consulta>[])
        if (c.id != id) c,
    ]);
  }
}
