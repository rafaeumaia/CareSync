import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de tema do app (claro/escuro/sistema).
///
/// Por padrão segue o tema do sistema. A tela de Configurações (seção 12 do
/// PROJECT_SPEC.md) terá um toggle que altera esse estado, propagando para
/// o app inteiro — o toggle em si ainda não está implementado nesta etapa.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;

  void toggleDark(bool isDark) =>
      state = isDark ? ThemeMode.dark : ThemeMode.light;
}
