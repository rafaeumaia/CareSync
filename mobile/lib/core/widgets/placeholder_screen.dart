import 'package:flutter/material.dart';

/// Tela de espaço reservado usada pelas rotas das 13 telas do CareSync
/// enquanto a implementação visual de cada uma ainda não foi feita.
///
/// Cada feature expõe sua própria tela em `presentation/`, que hoje apenas
/// delega para este widget — isso mantém o roteador (`core/router`) já
/// ligado à estrutura final de features, sem antecipar a implementação
/// visual das telas (fora do escopo desta etapa).
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tela ainda não implementada.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
