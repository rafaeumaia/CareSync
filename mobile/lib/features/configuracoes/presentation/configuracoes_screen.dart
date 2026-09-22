import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Configurações',
      icon: Icons.settings_outlined,
    );
  }
}
