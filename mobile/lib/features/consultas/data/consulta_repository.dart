import '../domain/consulta.dart';

/// Contrato de acesso às consultas.
///
/// Hoje implementado em memória por [InMemoryConsultaRepository]; a
/// implementação definitiva consumirá a API Django (CLAUDE.md), sem banco
/// local como fonte principal.
abstract interface class ConsultaRepository {
  Future<List<Consulta>> fetchAll();
  Future<Consulta> add(ConsultaDraft draft);
  Future<void> delete(int id);
}

/// Repositório em memória, iniciado com as consultas fixas do protótipo
/// (`ConsultasScreen.tsx`). Os dados duram enquanto o app estiver aberto.
class InMemoryConsultaRepository implements ConsultaRepository {
  InMemoryConsultaRepository({List<Consulta>? initial})
      : _items = [...(initial ?? seed)];

  static final seed = [
    Consulta(
      id: 1,
      doctor: 'Dr. Carlos Silva',
      specialty: 'Cardiologia',
      date: DateTime(2025, 10, 25),
      time: '15:30',
      location: 'Clínica Saúde Total - Sala 203',
      notes: 'Levar exames anteriores',
    ),
    Consulta(
      id: 2,
      doctor: 'Dra. Maria Santos',
      specialty: 'Geriatria',
      date: DateTime(2025, 10, 28),
      time: '10:00',
      location: 'Hospital Central - 3º andar',
    ),
  ];

  final List<Consulta> _items;

  @override
  Future<List<Consulta>> fetchAll() async => List.unmodifiable(_items);

  @override
  Future<Consulta> add(ConsultaDraft draft) async {
    final consulta = Consulta(
      // `id: Date.now()` no protótipo.
      id: DateTime.now().microsecondsSinceEpoch,
      doctor: draft.doctor,
      specialty: draft.specialty,
      date: draft.date,
      time: draft.time,
      location: draft.location,
      // No protótipo, observação vazia não mostra o quadro "💡".
      notes: draft.notes.isEmpty ? null : draft.notes,
    );
    _items.add(consulta);
    return consulta;
  }

  @override
  Future<void> delete(int id) async => _items.removeWhere((c) => c.id == id);
}
