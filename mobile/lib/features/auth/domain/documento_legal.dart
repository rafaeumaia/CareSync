/// Documentos que o usuário aceita no cadastro.
enum DocumentoLegal {
  termosDeUso('Termos de uso'),
  politicaDePrivacidade('Política de privacidade');

  const DocumentoLegal(this.title);

  final String title;
}
