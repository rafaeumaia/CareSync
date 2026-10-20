import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_picker_field.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/medicacao.dart';

/// Estado do formulário "Adicionar Medicação".
///
/// Fica com a tela (não com o diálogo), como o `formData` do protótipo:
/// fechar o diálogo sem adicionar mantém o que foi preenchido, e adicionar
/// limpa o formulário.
class AdicionarMedicacaoForm extends ChangeNotifier {
  AdicionarMedicacaoForm() {
    name.addListener(notifyListeners);
    dosage.addListener(notifyListeners);
  }

  final name = TextEditingController();
  final dosage = TextEditingController();
  String? _frequency;
  TimeOfDay? _time;

  String? get frequency => _frequency;
  set frequency(String? value) {
    _frequency = value;
    notifyListeners();
  }

  TimeOfDay? get time => _time;
  set time(TimeOfDay? value) {
    _time = value;
    notifyListeners();
  }

  /// O botão só habilita com todos os campos preenchidos, como no protótipo.
  bool get isComplete =>
      name.text.isNotEmpty &&
      dosage.text.isNotEmpty &&
      _frequency != null &&
      _time != null;

  MedicacaoDraft toDraft() => MedicacaoDraft(
    name: name.text,
    dosage: dosage.text,
    frequency: _frequency!,
    time: formatHhMm(_time!.hour, _time!.minute),
  );

  void reset() {
    name.clear();
    dosage.clear();
    _frequency = null;
    _time = null;
    notifyListeners();
  }

  @override
  void dispose() {
    name.dispose();
    dosage.dispose();
    super.dispose();
  }
}

/// Abre o diálogo "Adicionar Medicação". [onAdd] recebe os dados ao tocar
/// em "Adicionar Medicação"; o diálogo então fecha e o formulário é limpo.
Future<void> showAdicionarMedicacaoDialog({
  required BuildContext context,
  required AdicionarMedicacaoForm form,
  required Future<void> Function(MedicacaoDraft draft) onAdd,
}) {
  return showAppDialog<void>(
    context: context,
    title: 'Adicionar Medicação',
    builder: (dialogContext) =>
        _AdicionarMedicacaoFields(form: form, onAdd: onAdd),
  );
}

class _AdicionarMedicacaoFields extends StatelessWidget {
  const _AdicionarMedicacaoFields({required this.form, required this.onAdd});

  final AdicionarMedicacaoForm form;
  final Future<void> Function(MedicacaoDraft draft) onAdd;

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: form.time ?? TimeOfDay.now(),
    );
    if (picked != null) form.time = picked;
  }

  void _submit(BuildContext context) {
    final draft = form.toDraft();
    form.reset();
    Navigator.of(context).pop();
    onAdd(draft);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return ListenableBuilder(
      listenable: form,
      builder: (context, _) => Padding(
        // `space-y-4 py-4`.
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Nome do medicamento',
              placeholder: 'Ex: Losartana',
              variant: AppInputVariant.standard,
              controller: form.name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            gap,
            AppTextField(
              label: 'Dosagem',
              placeholder: 'Ex: 50mg',
              variant: AppInputVariant.standard,
              controller: form.dosage,
              textInputAction: TextInputAction.done,
            ),
            gap,
            AppSelectField(
              label: 'Frequência',
              placeholder: 'Selecione a frequência',
              options: frequenciasMedicacao,
              value: form.frequency,
              onChanged: (value) => form.frequency = value,
            ),
            gap,
            AppPickerField(
              label: 'Horário',
              value: form.time == null
                  ? null
                  : formatHhMm(form.time!.hour, form.time!.minute),
              emptyText: '--:--',
              icon: 'clock',
              onTap: () => _pickTime(context),
            ),
            gap,
            AppButton(
              label: 'Adicionar Medicação',
              height: 36,
              color: context.careSyncColors.success,
              onPressed: form.isComplete ? () => _submit(context) : null,
            ),
          ],
        ),
      ),
    );
  }
}
