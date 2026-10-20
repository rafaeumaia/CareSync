import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../../../core/widgets/tinted_icon_circle.dart';
import '../../domain/consulta.dart';

/// "dd/mm/aaaa às HH:mm", como no protótipo.
String _dateTimeLabel(Consulta c) => '${formatDdMmYyyy(c.date)} às ${c.time}';

/// Nome do médico (16px/600) e especialidade (14px, `muted-foreground`).
class _DoctorAndSpecialty extends StatelessWidget {
  const _DoctorAndSpecialty({required this.consulta});

  final Consulta consulta;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          consulta.doctor,
          style: AppTypography.inter(
            size: 16,
            lineHeight: 24,
            weight: FontWeight.w600,
            color: colors.cardForeground,
          ),
        ),
        Text(
          consulta.specialty,
          style: AppTypography.inter(
            size: 14,
            lineHeight: 20,
            color: colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Card de uma consulta da aba "Próximas" (padding de 16px):
/// - topo: estetoscópio `primary` em círculo de 48px, médico e
///   especialidade, e à direita os botões editar (sem ação no protótipo) e
///   excluir, 12px acima dos detalhes;
/// - detalhes, recuados 60px (`ml-15`) e separados por 8px: "📅 data às
///   horário", local com o ícone de pino e, se houver, a observação "💡"
///   num quadro `secondary` 8px mais abaixo (`mt-2`).
class UpcomingConsultaCard extends StatelessWidget {
  const UpcomingConsultaCard({
    super.key,
    required this.consulta,
    required this.onDelete,
  });

  final Consulta consulta;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final small = AppTypography.inter(size: 14, lineHeight: 20);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TintedIconCircle(icon: 'stethoscope', color: colors.primary),
              const SizedBox(width: 12),
              Expanded(child: _DoctorAndSpecialty(consulta: consulta)),
              const SizedBox(width: 8),
              // O botão de editar não tem ação no protótipo (sem `onClick`).
              _IconActionButton(
                icon: 'pen',
                color: colors.mutedForeground,
                semanticLabel: 'Editar consulta',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                key: ValueKey('delete-consulta-${consulta.id}'),
                icon: 'trash-2',
                color: colors.destructive,
                semanticLabel: 'Excluir consulta',
                onTap: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('📅', style: small.copyWith(color: colors.mutedForeground)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _dateTimeLabel(consulta),
                        style: small.copyWith(color: colors.cardForeground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    LucideIcon(
                      'map-pin',
                      size: 16,
                      color: colors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        consulta.location,
                        style: small.copyWith(color: colors.mutedForeground),
                      ),
                    ),
                  ],
                ),
                if (consulta.notes != null) ...[
                  // `space-y-2` + `mt-2`.
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(AppRadius.item),
                    ),
                    child: Text(
                      '💡 ${consulta.notes}',
                      style: small.copyWith(color: colors.mutedForeground),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de uma consulta da aba "Passadas": o card inteiro a 75% de
/// opacidade, estetoscópio cinza (`text-gray-400`) em círculo cinza
/// (`bg-gray-100`), médico, especialidade e "data às horário" 4px abaixo.
/// Não tem botões de ação.
class PastConsultaCard extends StatelessWidget {
  const PastConsultaCard({super.key, required this.consulta});

  final Consulta consulta;

  /// `gray-100` e `gray-400` do Tailwind v4.1 — não são tokens do tema no
  /// protótipo, então são mantidos iguais em claro e escuro.
  static const _gray100 = Color(0xFFF3F4F6);
  static const _gray400 = Color(0xFF99A1AF);

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Opacity(
      opacity: 0.75,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _gray100,
                shape: BoxShape.circle,
              ),
              child: const LucideIcon('stethoscope', size: 24, color: _gray400),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DoctorAndSpecialty(consulta: consulta),
                  const SizedBox(height: 4),
                  Text(
                    _dateTimeLabel(consulta),
                    style: AppTypography.inter(
                      size: 14,
                      lineHeight: 20,
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vazio de uma aba: 48px de padding vertical (`py-12`), ícone
/// opcional de 64px em `muted-foreground` 16px acima do texto centralizado.
class ConsultasEmptyState extends StatelessWidget {
  const ConsultasEmptyState({super.key, required this.message, this.icon});

  final String message;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            LucideIcon(icon!, size: 64, color: colors.mutedForeground),
            const SizedBox(height: 16),
          ],
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              size: 16,
              lineHeight: 24,
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão de ícone de 16px com 8px de padding (`p-2 rounded-lg`) que ganha
/// fundo `secondary` enquanto pressionado (`hover:bg-secondary`).
class _IconActionButton extends StatefulWidget {
  const _IconActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.semanticLabel,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final secondary = context.careSyncColors.secondary;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _pressed ? secondary : secondary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.item),
          ),
          child: LucideIcon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}
