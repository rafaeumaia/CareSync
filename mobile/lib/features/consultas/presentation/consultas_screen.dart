import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class ConsultasScreen extends StatelessWidget {
  const ConsultasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Consultas',
      icon: Icons.calendar_today_outlined,
    );
  }
}
