import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Abre um diálogo de confirmação fiel ao `AlertDialog` do protótipo
/// (`ui/alert-dialog.tsx`, usado no "Deseja sair?" de Configurações) e
/// retorna `true` se o usuário confirmar.
///
/// - fundo escurecido `bg-black/50`; tocar fora não fecha (como no Radix
///   AlertDialog); voltar equivale a cancelar;
/// - entrada/saída com fade + zoom de 95% em 200ms;
/// - caixa com fundo `background`, borda de 1px, cantos `rounded-lg`,
///   padding de 24px e `shadow-lg`; largura da tela menos 32px, até 512px
///   (`sm:max-w-lg`);
/// - [title] de 18px/600 e [description] de 14px em `muted-foreground`,
///   8px entre eles, centralizados abaixo de 640px (`text-center
///   sm:text-left`);
/// - 16px abaixo, os botões de 36px: abaixo de 640px empilhados com o de
///   confirmação em cima (`flex-col-reverse gap-2`); a partir de 640px, lado
///   a lado à direita. Cancelar é `outline`; confirmar usa [confirmColor]
///   (padrão `primary`).
Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  Color? confirmColor,
}) async {
  final confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) => _AppConfirmDialog(
      title: title,
      description: description,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmColor: confirmColor,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
  return confirmed ?? false;
}

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final media = MediaQuery.of(context);
    final isSmall = media.size.width < 640;
    final align = isSmall ? TextAlign.center : TextAlign.start;

    final cancel = AppButton(
      label: cancelLabel,
      variant: AppButtonVariant.outline,
      height: 36,
      expand: isSmall,
      onPressed: () => Navigator.of(context).pop(false),
    );
    final confirm = AppButton(
      label: confirmLabel,
      height: 36,
      color: confirmColor,
      expand: isSmall,
      onPressed: () => Navigator.of(context).pop(true),
    );

    return SafeArea(
      child: Center(
        child: Padding(
          // `max-w-[calc(100%-2rem)]`.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.item),
                  border: Border.all(color: colors.border),
                  boxShadow: AppShadows.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: align,
                      style: AppTypography.inter(
                        size: 18,
                        lineHeight: 28,
                        weight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      textAlign: align,
                      style: AppTypography.inter(
                        size: 14,
                        lineHeight: 20,
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isSmall) ...[
                      confirm,
                      const SizedBox(height: 8),
                      cancel,
                    ] else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [cancel, const SizedBox(width: 8), confirm],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
