import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Campo de formulário do CareSync: `Label` + `Input` do protótipo Figma
/// Make (`ui/label.tsx` e `ui/input.tsx`), com a customização usada nos
/// formulários das telas (`h-12 bg-input-background border-0`).
///
/// - Label: 14px (`text-sm`), peso 500, `leading-none`, 8px acima do campo
///   (`space-y-2`).
/// - Campo: 48px de altura, fundo `input-background`, sem borda, cantos
///   `rounded-md`, 12px de padding horizontal (`px-3`), texto 16px
///   (`text-base`, 14px a partir de 768px por `md:text-sm`), placeholder em
///   `muted-foreground`.
/// - Foco: anel externo de 3px em `ring` a 50% (`focus-visible:ring-[3px]
///   ring-ring/50`), com a transição de 150ms do `transition-[box-shadow]`.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownFocusNode;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_onFocusChange);
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final textTheme = Theme.of(context).textTheme;
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final fontSize = isTablet ? 14.0 : 16.0;

    final labelStyle = textTheme.labelMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.foreground,
    );
    final inputStyle = textTheme.bodyLarge?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
      color: colors.foreground,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // O `htmlFor` do Label foca o campo ao ser tocado.
        GestureDetector(
          onTap: _focusNode.requestFocus,
          child: Text(widget.label, style: labelStyle),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.4, 0, 0.2, 1),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.inputBackground,
            borderRadius: BorderRadius.circular(AppRadius.button),
            boxShadow: [
              BoxShadow(
                color: _focusNode.hasFocus
                    ? colors.ring.withValues(alpha: 0.5)
                    : colors.ring.withValues(alpha: 0),
                spreadRadius: 3,
              ),
            ],
          ),
          child: TextSelectionTheme(
            // `selection:bg-primary`.
            data: TextSelectionThemeData(
              selectionColor: colors.primary,
              selectionHandleColor: colors.primary,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: widget.obscureText,
              obscuringCharacter: '•',
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              onSubmitted: widget.onSubmitted,
              style: inputStyle,
              // O cursor do navegador usa a cor do texto (`caret-color: auto`).
              cursorColor: colors.foreground,
              // Fundo, borda e anel de foco são desenhados pelo container
              // acima; todas as bordas/preenchimento do
              // `inputDecorationTheme` global são desligados aqui (o
              // `InputDecoration.collapsed` ainda herdaria o `focusedBorder`
              // do tema).
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: inputStyle?.copyWith(color: colors.mutedForeground),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
