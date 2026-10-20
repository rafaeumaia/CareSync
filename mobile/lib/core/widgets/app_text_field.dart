import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Variações do `Input`/`Textarea` do protótipo Figma Make usadas nas telas.
enum AppInputVariant {
  /// `Input` com `h-12 bg-input-background border-0` (Login, Cadastro):
  /// 48px de altura, sem borda.
  large,

  /// `Input` padrão (`ui/input.tsx`), usado nos formulários dos diálogos:
  /// 36px de altura (`h-9`) e borda de 1px transparente que assume a cor
  /// `ring` no foco (`focus-visible:border-ring`).
  standard,

  /// `Textarea` padrão (`ui/textarea.tsx`): mínimo de 64px (`min-h-16`),
  /// padding `px-3 py-2`, cresce com o conteúdo (`field-sizing-content`) e
  /// tem a mesma borda do [standard].
  multiline,
}

/// Label de campo (`ui/label.tsx`): 14px (`text-sm`), peso 500,
/// `leading-none`. Tocar nela executa [onTap] (equivalente ao `htmlFor`).
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTypography.inter(
          size: 14,
          lineHeight: 14,
          weight: FontWeight.w500,
          color: context.careSyncColors.foreground,
        ),
      ),
    );
  }
}

/// Caixa visual dos campos: fundo `input-background`, cantos `rounded-md`,
/// padding horizontal de 12px (`px-3`) e, com foco, o anel externo de 3px
/// em `ring` a 50% (`focus-visible:ring-[3px] ring-ring/50`), com a
/// transição de 150ms do `transition-[color,box-shadow]`.
class AppInputBox extends StatelessWidget {
  const AppInputBox({
    super.key,
    required this.variant,
    required this.focused,
    required this.child,
  });

  final AppInputVariant variant;
  final bool focused;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final bordered = variant != AppInputVariant.large;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: const Cubic(0.4, 0, 0.2, 1),
      height: switch (variant) {
        AppInputVariant.large => 48,
        AppInputVariant.standard => 36,
        AppInputVariant.multiline => null,
      },
      constraints: variant == AppInputVariant.multiline
          ? const BoxConstraints(minHeight: 64)
          : null,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: variant == AppInputVariant.multiline ? 8 : 0,
      ),
      alignment: variant == AppInputVariant.multiline
          ? Alignment.topLeft
          : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: bordered
            ? Border.all(
                color: focused ? colors.ring : colors.ring.withValues(alpha: 0),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: focused
                ? colors.ring.withValues(alpha: 0.5)
                : colors.ring.withValues(alpha: 0),
            spreadRadius: 3,
          ),
        ],
      ),
      child: child,
    );
  }

  /// Estilo do texto digitado: 16px (`text-base`), 14px a partir de 768px
  /// (`md:text-sm`), altura de linha 1.5, cor `foreground`.
  static TextStyle textStyle(BuildContext context) {
    final isTablet =
        MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
    final size = isTablet ? 14.0 : 16.0;
    return AppTypography.inter(
      size: size,
      lineHeight: size * 1.5,
      color: context.careSyncColors.foreground,
    );
  }
}

/// Campo de formulário do CareSync: [AppFieldLabel] + campo de texto,
/// separados por 8px (`space-y-2`), com o placeholder em
/// `muted-foreground`. A aparência do campo vem de [variant].
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.variant = AppInputVariant.large,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onSubmitted,
  });

  final String label;
  final AppInputVariant variant;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? placeholder;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
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
    final inputStyle = AppInputBox.textStyle(context);
    final multiline = widget.variant == AppInputVariant.multiline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFieldLabel(widget.label, onTap: _focusNode.requestFocus),
        const SizedBox(height: 8),
        AppInputBox(
          variant: widget.variant,
          focused: _focusNode.hasFocus,
          child: TextSelectionTheme(
            // `selection:bg-primary`.
            data: TextSelectionThemeData(
              selectionColor: colors.primary,
              selectionHandleColor: colors.primary,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: multiline
                  ? TextInputType.multiline
                  : widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              minLines: multiline ? 1 : null,
              maxLines: multiline ? null : 1,
              obscureText: widget.obscureText,
              obscuringCharacter: '•',
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              onSubmitted: widget.onSubmitted,
              style: inputStyle,
              // O cursor do navegador usa a cor do texto (`caret-color: auto`).
              cursorColor: colors.foreground,
              // Fundo, borda e anel de foco são desenhados por
              // [AppInputBox]; todas as bordas/preenchimento do
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
                hintStyle: inputStyle.copyWith(color: colors.mutedForeground),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
