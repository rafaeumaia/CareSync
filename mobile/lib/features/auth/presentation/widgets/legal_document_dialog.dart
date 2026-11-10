import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../data/legal_documents_repository.dart';
import '../../domain/documento_legal.dart';

/// Abre o texto de [documento] num diálogo padrão (rola quando é longo),
/// com indicador de carregamento enquanto o texto chega e uma mensagem se
/// ele não puder ser carregado.
Future<void> showLegalDocumentDialog({
  required BuildContext context,
  required DocumentoLegal documento,
  required LegalDocumentsRepository repository,
}) {
  // Uma busca por abertura, mesmo que o diálogo seja reconstruído.
  final future = repository.fetch(documento);
  return showAppDialog<void>(
    context: context,
    title: documento.title,
    builder: (_) => _LegalDocumentBody(future: future),
  );
}

class _LegalDocumentBody extends StatelessWidget {
  const _LegalDocumentBody({required this.future});

  final Future<String> future;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return FutureBuilder<String>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),
            ),
          );
        }
        final failed = snapshot.hasError;
        return Text(
          failed
              ? 'Não foi possível carregar o texto. Tente novamente.'
              : snapshot.data!,
          style: AppTypography.inter(
            size: 14,
            lineHeight: 20,
            color: failed ? colors.destructive : colors.mutedForeground,
          ),
        );
      },
    );
  }
}
