import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Chat',
      icon: Icons.chat_bubble_outline,
    );
  }
}
