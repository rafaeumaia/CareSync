import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class AlimentacaoScreen extends StatelessWidget {
  const AlimentacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Alimentação',
      icon: Icons.restaurant_outlined,
    );
  }
}
