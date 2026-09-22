import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class MedicacoesScreen extends StatelessWidget {
  const MedicacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Medicações',
      icon: Icons.medication_outlined,
    );
  }
}
