import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/current_user.dart';
import '../data/indicadores_repository.dart';
import '../domain/indicador.dart';

/// Repositório de indicadores. Trocar pela implementação HTTP quando a API
/// Django existir.
final indicadoresRepositoryProvider = Provider<IndicadoresRepository>(
  (ref) => InMemoryIndicadoresRepository(today: ref.watch(currentDateProvider)),
);

/// Todas as medições de indicadores.
final indicadoresProvider =
    AsyncNotifierProvider<IndicadoresNotifier, List<IndicatorRecord>>(
      IndicadoresNotifier.new,
    );

class IndicadoresNotifier extends AsyncNotifier<List<IndicatorRecord>> {
  @override
  Future<List<IndicatorRecord>> build() =>
      ref.watch(indicadoresRepositoryProvider).fetchRecords();

  /// Registra uma medição; cards e gráficos são atualizados na hora.
  Future<IndicatorRecord> add(IndicatorRecordDraft draft) async {
    final record = await ref
        .read(indicadoresRepositoryProvider)
        .addRecord(draft);
    state = AsyncData([...?state.value, record]);
    return record;
  }
}
