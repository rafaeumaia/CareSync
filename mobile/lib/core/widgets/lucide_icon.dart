import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone da biblioteca lucide (v0.487.0, a mesma do protótipo), renderizado
/// a partir do SVG original em `assets/icons/`.
///
/// O traço usa [color] (`stroke="currentColor"` do lucide). [fillColor],
/// quando informado, preenche as formas do ícone — equivalente às classes
/// `fill-*` do protótipo (ex.: `fill-[#2F80ED]/20` no item ativo do
/// BottomNav).
class LucideIcon extends StatelessWidget {
  const LucideIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
    this.fillColor,
  });

  /// Nome do arquivo do ícone, sem extensão (ex.: `'house'`).
  final String name;
  final double size;

  /// Cor do traço. Padrão: cor do [IconTheme] atual.
  final Color? color;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final stroke = color ?? IconTheme.of(context).color ?? Colors.black;
    return SvgPicture(
      _LucideSvgLoader(
        'assets/icons/$name.svg',
        fillColor: fillColor,
        theme: SvgTheme(currentColor: stroke),
      ),
      width: size,
      height: size,
    );
  }
}

class _LucideSvgLoader extends SvgLoader<String> {
  const _LucideSvgLoader(this.assetName, {this.fillColor, super.theme});

  final String assetName;
  final Color? fillColor;

  @override
  Future<String?> prepareMessage(BuildContext? context) =>
      rootBundle.loadString(assetName);

  @override
  String provideSvg(String? message) {
    final svg = message ?? '';
    final fill = fillColor;
    if (fill == null) return svg;
    final argb = fill.toARGB32();
    final hex = (argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
    final opacity = ((argb >> 24) & 0xFF) / 255;
    // O primeiro `fill="none"` é o atributo do `<svg>` raiz, herdado por
    // todas as formas do ícone.
    return svg.replaceFirst(
      'fill="none"',
      'fill="#$hex" fill-opacity="${opacity.toStringAsFixed(3)}"',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _LucideSvgLoader &&
      other.assetName == assetName &&
      other.fillColor == fillColor &&
      other.theme == theme;

  @override
  int get hashCode => Object.hash(assetName, fillColor, theme);
}
