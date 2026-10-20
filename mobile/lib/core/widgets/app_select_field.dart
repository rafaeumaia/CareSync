import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_text_field.dart';
import 'lucide_icon.dart';

/// Campo de seleção do protótipo (`ui/select.tsx`): [AppFieldLabel] e,
/// 8px abaixo, o gatilho com a aparência do `Input` padrão
/// ([AppInputVariant.standard], 36px), texto de 14px (`text-sm`) — o
/// [placeholder] em `muted-foreground` — e o chevron de 16px em
/// `muted-foreground` a 50% de opacidade.
///
/// Tocar abre a lista de [options] logo abaixo do gatilho (4px,
/// `translate-y-1`), ou acima, se não couber: fundo `popover`, borda de
/// 1px, cantos `rounded-md`, sombra `shadow-md` e padding de 4px; cada
/// item tem 14px de texto com `py-1.5 pl-2 pr-8`, fica `accent` com texto
/// branco ao ser tocado e, se selecionado, mostra o check de 16px à direita.
class AppSelectField extends StatefulWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String placeholder;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  State<AppSelectField> createState() => _AppSelectFieldState();
}

class _AppSelectFieldState extends State<AppSelectField> {
  final _triggerKey = GlobalKey();
  bool _open = false;

  Future<void> _openMenu() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final box = _triggerKey.currentContext!.findRenderObject()! as RenderBox;
    final rect = box.localToGlobal(Offset.zero) & box.size;

    setState(() => _open = true);
    final selected = await Navigator.of(context).push(
      _SelectMenuRoute(
        anchor: rect,
        options: widget.options,
        value: widget.value,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
      ),
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final value = widget.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(widget.label, onTap: _openMenu),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: widget.label,
          value: value,
          child: GestureDetector(
            key: _triggerKey,
            behavior: HitTestBehavior.opaque,
            onTap: _openMenu,
            child: AppInputBox(
              variant: AppInputVariant.standard,
              focused: _open,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? widget.placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        size: 14,
                        lineHeight: 20,
                        color: value == null
                            ? colors.mutedForeground
                            : colors.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Opacity(
                    opacity: 0.5,
                    child: LucideIcon(
                      'chevron-down',
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectMenuRoute extends PopupRoute<String> {
  _SelectMenuRoute({
    required this.anchor,
    required this.options,
    required this.value,
    required this.barrierLabel,
  });

  final Rect anchor;
  final List<String> options;
  final String? value;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  /// `animate-in` / `animate-out` do tw-animate-css (150ms).
  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SelectMenu(
      anchor: anchor,
      options: options,
      value: value,
      animation: animation,
    );
  }
}

class _SelectMenu extends StatefulWidget {
  const _SelectMenu({
    required this.anchor,
    required this.options,
    required this.value,
    required this.animation,
  });

  final Rect anchor;
  final List<String> options;
  final String? value;
  final Animation<double> animation;

  @override
  State<_SelectMenu> createState() => _SelectMenuState();
}

class _SelectMenuState extends State<_SelectMenu> {
  /// Item realçado: começa no selecionado (o Radix foca o item atual ao
  /// abrir) e segue o toque.
  late String? _highlighted = widget.value;

  static const _itemHeight = 32.0; // `py-1.5` + 20px de texto.
  static const _sideOffset = 4.0; // `translate-y-1`.
  static const _margin = 8.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final media = MediaQuery.of(context);
    final anchor = widget.anchor;

    // Viewport `p-1` + borda de 1px.
    final contentHeight = widget.options.length * _itemHeight + 8 + 2;
    final spaceBelow =
        media.size.height -
        media.viewInsets.bottom -
        media.padding.bottom -
        anchor.bottom -
        _sideOffset -
        _margin;
    final spaceAbove = anchor.top - media.padding.top - _sideOffset - _margin;
    // Como o `avoidCollisions` do Radix: abre para cima se não couber.
    final openBelow = spaceBelow >= contentHeight || spaceBelow >= spaceAbove;
    final maxHeight = math.max(
      _itemHeight,
      openBelow ? spaceBelow : spaceAbove,
    );
    final height = math.min(contentHeight, maxHeight);

    final curved = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOut,
    );

    final menu = Container(
      width: anchor.width,
      height: height,
      decoration: BoxDecoration(
        color: colors.card, // `popover` = `card` nos dois temas.
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
        // `shadow-md`.
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in widget.options) _buildItem(option, colors),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: anchor.left,
          top: openBelow ? anchor.bottom + _sideOffset : null,
          bottom: openBelow
              ? null
              : media.size.height - anchor.top + _sideOffset,
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              // `zoom-in-95`.
              scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
              alignment: openBelow
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              child: SlideTransition(
                // `slide-in-from-top-2` / `slide-in-from-bottom-2` (8px).
                position: Tween<Offset>(
                  begin: Offset(0, (openBelow ? -8 : 8) / height),
                  end: Offset.zero,
                ).animate(curved),
                child: Material(type: MaterialType.transparency, child: menu),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String option, CareSyncColors colors) {
    final highlighted = option == _highlighted;
    final selected = option == widget.value;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _highlighted = option),
        onTapCancel: () => setState(() => _highlighted = widget.value),
        onTap: () => Navigator.of(context).pop(option),
        child: Container(
          height: _itemHeight,
          padding: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: highlighted ? colors.accent : null,
            borderRadius: BorderRadius.circular(8), // `rounded-sm`.
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    size: 14,
                    lineHeight: 20,
                    // `focus:text-accent-foreground` (branco).
                    color: highlighted
                        ? colors.primaryForeground
                        : colors.foreground,
                  ),
                ),
              ),
              // `pr-8`, com o indicador `absolute right-2 size-3.5` (check
              // de 16px) do item selecionado.
              SizedBox(
                width: 32,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: OverflowBox(
                              maxWidth: 16,
                              maxHeight: 16,
                              child: LucideIcon(
                                'check',
                                size: 16,
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
