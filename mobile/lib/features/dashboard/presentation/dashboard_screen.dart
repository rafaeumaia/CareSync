import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Início',
      icon: Icons.home_outlined,
    );
  }
}
