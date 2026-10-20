import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_picker_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/consulta.dart';

/// Estado do formulário "Nova Consulta".
///
/// Fica com a tela (não com o diálogo), como o `formData` do protótipo:
/// fechar o diálogo sem adicionar mantém o que foi digitado, e adicionar
/// limpa o formulário.
class NovaConsultaForm {
  final doctor = TextEditingController();
  final specialty = TextEditingController();
  final location = TextEditingController();
  final notes = TextEditingController();
  final date = ValueNotifier<DateTime?>(null);
  final time = ValueNotifier<TimeOfDay?>(null);

  ConsultaDraft toDraft() => ConsultaDraft(
        doctor: doctor.text,
        specialty: specialty.text,
        date: date.value!,
        time: time.value == null
            ? ''
            : formatHhMm(time.value!.hour, time.value!.minute),
        location: location.text,
        notes: notes.text,
      );

  void reset() {
    for (final c in [doctor, specialty, location, notes]) {
      c.clear();
    }
    date.value = null;
    time.value = null;
  }

  void dispose() {
    for (final c in [doctor, specialty, location, notes]) {
      c.dispose();
    }
    date.dispose();
    time.dispose();
  }
}

/// Abre o diálogo "Nova Consulta". [onAdd] recebe os dados ao tocar em
/// "Adicionar Consulta"; o diálogo então fecha e o formulário é limpo.
Future<void> showNovaConsultaDialog({
  required BuildContext context,
  required NovaConsultaForm form,
  required DateTime today,
  required Future<void> Function(ConsultaDraft draft) onAdd,
}) {
  return showAppDialog<void>(
    context: context,
    title: 'Nova Consulta',
    builder: (dialogContext) => _NovaConsultaFields(
      form: form,
      today: today,
      onAdd: onAdd,
    ),
  );
}

class _NovaConsultaFields extends StatelessWidget {
  const _NovaConsultaFields({
    required this.form,
    required this.today,
    required this.onAdd,
  });

  final NovaConsultaForm form;
  final DateTime today;
  final Future<void> Function(ConsultaDraft draft) onAdd;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: form.date.value ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null) form.date.value = picked;
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: form.time.value ?? TimeOfDay.now(),
    );
    if (picked != null) form.time.value = picked;
  }

  Future<void> _submit(BuildContext context) async {
    // Sem data a consulta não entraria em nenhuma das abas (no protótipo ela
    // simplesmente desaparece); em vez disso, o seletor de data é aberto.
    if (form.date.value == null) {
      await _pickDate(context);
      return;
    }
    final navigator = Navigator.of(context);
    await onAdd(form.toDraft());
    form.reset();
    navigator.pop();
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
            label: 'Médico',
            placeholder: 'Nome do médico',
            variant: AppInputVariant.standard,
            controller: form.doctor,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          gap,
          AppTextField(
            label: 'Especialidade',
            placeholder: 'Ex: Cardiologia',
            variant: AppInputVariant.standard,
            controller: form.specialty,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: form.date,
                  builder: (context, date, _) => AppPickerField(
                    label: 'Data',
                    value: date == null ? null : formatDdMmYyyy(date),
                    emptyText: 'dd/mm/aaaa',
                    icon: 'calendar',
                    onTap: () => _pickDate(context),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: form.time,
                  builder: (context, time, _) => AppPickerField(
                    label: 'Horário',
                    value: time == null
                        ? null
                        : formatHhMm(time.hour, time.minute),
                    emptyText: '--:--',
                    icon: 'clock',
                    onTap: () => _pickTime(context),
                  ),
                ),
              ),
            ],
          ),
          gap,
          AppTextField(
            label: 'Local',
            placeholder: 'Clínica ou hospital',
            variant: AppInputVariant.standard,
            controller: form.location,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
          ),
          gap,
          AppTextField(
            label: 'Observações',
            placeholder: 'Informações adicionais...',
            variant: AppInputVariant.multiline,
            controller: form.notes,
            textCapitalization: TextCapitalization.sentences,
          ),
          gap,
          AppButton(
            label: 'Adicionar Consulta',
            height: 36,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }
}
