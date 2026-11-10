import '../domain/documento_legal.dart';

/// Contrato de acesso ao texto dos documentos legais.
///
/// A implementação definitiva buscará o texto vigente na API Django
/// (CLAUDE.md); até lá, [PendingLegalDocumentsRepository] informa que o
/// texto ainda não foi publicado.
abstract interface class LegalDocumentsRepository {
  Future<String> fetch(DocumentoLegal documento);
}

/// Enquanto o texto oficial não existe, devolve um aviso em vez de um
/// texto jurídico inventado.
class PendingLegalDocumentsRepository implements LegalDocumentsRepository {
  const PendingLegalDocumentsRepository();

  @override
  Future<String> fetch(DocumentoLegal documento) async =>
      'O texto completo de "${documento.title}" ainda não foi publicado. '
      'Ele estará disponível aqui antes do lançamento do CareSync.';
}
