/// Recomendação alimentar exibida no card "Recomendações".
class Recomendacao {
  const Recomendacao({required this.emoji, required this.text});

  final String emoji;
  final String text;
}

/// Recomendações fixas do protótipo (`recommendations`), na mesma ordem.
const recomendacoesAlimentacao = [
  Recomendacao(emoji: '🥗', text: 'Prefira alimentos ricos em fibras.'),
  Recomendacao(emoji: '🧂', text: 'Evite excesso de sal e açúcar.'),
  Recomendacao(emoji: '🍎', text: 'Inclua frutas todos os dias.'),
];
