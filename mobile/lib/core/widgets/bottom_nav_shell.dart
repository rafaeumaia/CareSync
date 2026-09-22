import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Casca de navegação das 4 abas fixas do BottomNav (PROJECT_SPEC.md,
/// seção 4): Início, Agenda, Saúde, Relatórios.
///
/// Usada como `builder` de um `StatefulShellRoute.indexedStack` em
/// `core/router/app_router.dart`, preservando o estado de cada aba ao
/// alternar entre elas.
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (label: 'Início', icon: Icons.home_outlined, activeIcon: Icons.home),
    (
      label: 'Agenda',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
    ),
    (
      label: 'Saúde',
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
    ),
    (
      label: 'Relatórios',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: [
          for (final item in _items)
            BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
