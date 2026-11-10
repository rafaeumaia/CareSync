import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_picker_field.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Abre o diálogo "Adicionar Refeição" (`AlimentacaoScreen.tsx`): nome,
/// horário e descrição, e o botão verde "Adicionar".
///
/// Como no protótipo, "Adicionar" só fecha o diálogo e chama [onAdd] (que
/// mostra o toast) — a refeição não entra na lista — e o formulário começa
/// vazio a cada abertura. Os campos, não controlados no protótipo, aqui são
/// controlados.
Future<void> showAdicionarRefeicaoDialog({
  required BuildContext context,
  required VoidCallback onAdd,
}) {
  return showAppDialog<void>(
    context: context,
    title: 'Adicionar Refeição',
    builder: (dialogContext) => _AdicionarRefeicaoFields(onAdd: onAdd),
  );
}

class _AdicionarRefeicaoFields extends StatefulWidget {
  const _AdicionarRefeicaoFields({required this.onAdd});

  final VoidCallback onAdd;

  @override
  State<_AdicionarRefeicaoFields> createState() =>
      _AdicionarRefeicaoFieldsState();
}

class _AdicionarRefeicaoFieldsState extends State<_AdicionarRefeicaoFields> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  TimeOfDay? _time;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) setState(() => _time = picked);
  }

  void _submit() {
    Navigator.of(context).pop();
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return Padding(
      // `space-y-4 py-4`.
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nome da refeição',
            placeholder: 'Ex: Lanche da tarde',
            variant: AppInputVariant.standard,
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          gap,
          AppPickerField(
            label: 'Horário',
            value: _time == null
                ? null
                : formatHhMm(_time!.hour, _time!.minute),
            emptyText: '--:--',
            icon: 'clock',
            onTap: _pickTime,
          ),
          gap,
          AppTextField(
            label: 'Descrição',
            placeholder: 'O que foi consumido...',
            variant: AppInputVariant.multiline,
            controller: _description,
            textCapitalization: TextCapitalization.sentences,
          ),
          gap,
          AppButton(
            label: 'Adicionar',
            height: 36,
            color: context.careSyncColors.success,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
