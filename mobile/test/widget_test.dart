import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:caresync/main.dart';
import 'package:caresync/core/router/route_paths.dart';

void main() {
  testWidgets('App inicia na Splash e aplica o tema do CareSync',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CareSyncApp()),
    );
    // A Splash tem uma animação de pulso infinita (`repeat`), então usamos
    // `pump` com uma duração limitada em vez de `pumpAndSettle`.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('CareSync'), findsWidgets);

    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp).first,
    );
    expect(materialApp.title, 'CareSync');
  });

  testWidgets('RoutePaths.splash é a rota inicial esperada',
      (WidgetTester tester) async {
    expect(RoutePaths.splash, '/splash');
  });
}
