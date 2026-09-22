import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Cadastro',
      icon: Icons.person_add_outlined,
    );
  }
}
