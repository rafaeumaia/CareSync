import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'lucide_icon.dart';

/// Abre um diálogo modal do CareSync, fiel ao `Dialog` do protótipo
/// (`ui/dialog.tsx`) com `DialogContent className="max-w-md max-h-[90vh]
/// overflow-y-auto"`:
/// - fundo escurecido `bg-black/50`; tocar fora fecha;
/// - entrada/saída com fade + zoom de 95% em 200ms;
/// - conteúdo centralizado, fundo `background`, borda de 1px `border`,
///   cantos `rounded-lg`, padding de 24px e sombra `shadow-lg`;
/// - largura de até 448px (`max-w-md`), ou 512px a partir de 640px de tela
///   (`sm:max-w-lg`); em telas menores que 448px, ocupa toda a largura
///   (o `max-w-md` substitui o `max-w-[calc(100%-2rem)]` padrão);
/// - altura máxima de 90% da tela, com rolagem interna;
/// - título de 18px/600 (`text-lg leading-none font-semibold`),
///   centralizado abaixo de 640px e alinhado à esquerda acima
///   (`text-center sm:text-left`), 16px acima do conteúdo (`gap-4`);
/// - botão de fechar (X de 16px, opacidade 70%) a 16px do canto.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (dialogContext, _, _) =>
        _AppDialog(title: title, builder: builder),
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppDialog extends StatelessWidget {
  const _AppDialog({required this.title, required this.builder});

  final String title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final maxWidth = screenWidth >= 640 ? 512.0 : 448.0;
    final isSmall = screenWidth < 640;
    final availableHeight = media.size.height -
        media.viewInsets.bottom -
        media.padding.top -
        media.padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: media.padding.top,
        bottom: media.viewInsets.bottom + media.padding.bottom,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: availableHeight * 0.9,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(AppRadius.item),
                border: Border.all(color: colors.border),
                boxShadow: AppShadows.lg,
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign:
                              isSmall ? TextAlign.center : TextAlign.start,
                          style: AppTypography.inter(
                            size: 18,
                            lineHeight: 18,
                            weight: FontWeight.w600,
                            color: colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Builder(builder: builder),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Semantics(
                      button: true,
                      label: 'Fechar',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).maybePop(),
                        // Área de toque maior que o ícone; o X fica a 16px
                        // do canto, como no protótipo.
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Opacity(
                            opacity: 0.7,
                            child: LucideIcon(
                              'x',
                              size: 16,
                              color: colors.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
