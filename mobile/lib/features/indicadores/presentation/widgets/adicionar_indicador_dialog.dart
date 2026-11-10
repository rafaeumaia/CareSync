import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_picker_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/lucide_icon.dart';
import '../../domain/indicador.dart';
import '../../domain/indicator_validation.dart';
import 'indicator_card.dart';

/// Abre o diálogo "Adicionar Indicador":
/// - grade 2×2 com os indicadores; o escolhido fica em [selected], que
///   pertence à tela (no protótipo a escolha continua marcada ao reabrir);
/// - escolhido um indicador, aparecem os campos de valor ("Valor", ou
///   "Sistólica" e "Diastólica" na pressão arterial), "Data e hora" e o
///   botão "Adicionar Registro". Os campos começam vazios a cada abertura;
/// - "Adicionar Registro" valida os campos ([validateIndicatorForm]); com
///   erro, mostra as mensagens e mantém o diálogo aberto; sem erro, chama
///   [onAdd] com a medição e fecha o diálogo.
Future<void> showAdicionarIndicadorDialog({
  required BuildContext context,
  required ValueNotifier<IndicatorType?> selected,
  required Future<void> Function(IndicatorRecordDraft draft) onAdd,
  DateTime Function() clock = DateTime.now,
}) {
  return showAppDialog<void>(
    context: context,
    title: 'Adicionar Indicador',
    builder: (dialogContext) => _AdicionarIndicadorFields(
      selected: selected,
      onAdd: onAdd,
      clock: clock,
    ),
  );
}

class _AdicionarIndicadorFields extends StatefulWidget {
  const _AdicionarIndicadorFields({
    required this.selected,
    required this.onAdd,
    required this.clock,
  });

  final ValueNotifier<IndicatorType?> selected;
  final Future<void> Function(IndicatorRecordDraft draft) onAdd;
  final DateTime Function() clock;

  @override
  State<_AdicionarIndicadorFields> createState() =>
      _AdicionarIndicadorFieldsState();
}

class _AdicionarIndicadorFieldsState extends State<_AdicionarIndicadorFields> {
  final _value = TextEditingController();
  final _diastolic = TextEditingController();
  DateTime? _dateTime;
  IndicatorFormErrors _errors = const IndicatorFormErrors();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.selected.addListener(_onTypeChanged);
  }

  @override
  void dispose() {
    widget.selected.removeListener(_onTypeChanged);
    _value.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  /// Trocar o indicador descarta os erros do anterior.
  void _onTypeChanged() =>
      setState(() => _errors = const IndicatorFormErrors());

  /// `<input type="datetime-local">`: escolhe a data e depois o horário.
  Future<void> _pickDateTime() async {
    final now = widget.clock();
    final initial = _dateTime ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _errors = IndicatorFormErrors(
        value: _errors.value,
        diastolic: _errors.diastolic,
      );
    });
  }

  Future<void> _register(IndicatorType type) async {
    if (_saving) return;
    final errors = validateIndicatorForm(
      type: type,
      valueText: _value.text,
      diastolicText: _diastolic.text,
      dateTime: _dateTime,
      now: widget.clock(),
    );
    if (!errors.isValid) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    await widget.onAdd(
      IndicatorRecordDraft(
        type: type,
        recordedAt: _dateTime!,
        value: parseMeasurement(_value.text)!,
        diastolic: type == IndicatorType.pressure
            ? parseMeasurement(_diastolic.text)
            : null,
      ),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    final dateTime = _dateTime;
    const numberKeyboard = TextInputType.numberWithOptions(decimal: true);
    return ValueListenableBuilder(
      valueListenable: widget.selected,
      builder: (context, selected, _) => Padding(
        // `space-y-4 py-4`.
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `grid grid-cols-2 gap-3`.
            for (var row = 0; row < IndicatorType.values.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < 2; col++) ...[
                      if (col > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _IndicatorOption(
                          type: IndicatorType.values[row + col],
                          selected: selected == IndicatorType.values[row + col],
                          onTap: () => widget.selected.value =
                              IndicatorType.values[row + col],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (selected != null) ...[
              gap,
              if (selected == IndicatorType.pressure)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        key: const ValueKey('campo-sistolica'),
                        label: 'Sistólica',
                        placeholder: 'mmHg',
                        variant: AppInputVariant.standard,
                        controller: _value,
                        keyboardType: numberKeyboard,
                        textInputAction: TextInputAction.next,
                        errorText: _errors.value,
                        onChanged: (_) => _clearValueError(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        key: const ValueKey('campo-diastolica'),
                        label: 'Diastólica',
                        placeholder: 'mmHg',
                        variant: AppInputVariant.standard,
                        controller: _diastolic,
                        keyboardType: numberKeyboard,
                        textInputAction: TextInputAction.done,
                        errorText: _errors.diastolic,
                        onChanged: (_) => _clearDiastolicError(),
                      ),
                    ),
                  ],
                )
              else
                AppTextField(
                  key: const ValueKey('campo-valor'),
                  label: 'Valor',
                  placeholder: 'Digite o valor',
                  variant: AppInputVariant.standard,
                  controller: _value,
                  keyboardType: numberKeyboard,
                  textInputAction: TextInputAction.done,
                  errorText: _errors.value,
                  onChanged: (_) => _clearValueError(),
                ),
              gap,
              AppPickerField(
                label: 'Data e hora',
                value: dateTime == null
                    ? null
                    : '${formatDdMmYyyy(dateTime)} '
                          '${formatHhMm(dateTime.hour, dateTime.minute)}',
                emptyText: 'dd/mm/aaaa --:--',
                icon: 'calendar',
                errorText: _errors.dateTime,
                onTap: _pickDateTime,
              ),
              gap,
              AppButton(
                label: 'Adicionar Registro',
                height: 36,
                color: context.careSyncColors.success,
                onPressed: _saving ? null : () => _register(selected),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _clearValueError() {
    if (_errors.value == null) return;
    setState(
      () => _errors = IndicatorFormErrors(
        diastolic: _errors.diastolic,
        dateTime: _errors.dateTime,
      ),
    );
  }

  void _clearDiastolicError() {
    if (_errors.diastolic == null) return;
    setState(
      () => _errors = IndicatorFormErrors(
        value: _errors.value,
        dateTime: _errors.dateTime,
      ),
    );
  }
}

/// Opção da grade: padding de 16px, cantos `rounded-lg`, borda de 2px
/// (`border` do tema; `success` quando escolhida, com fundo `success` a 5%;
/// `success` a 50% enquanto pressionada), ícone de 24px na cor do
/// indicador, 8px acima do nome (12px, centralizado).
class _IndicatorOption extends StatefulWidget {
  const _IndicatorOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final IndicatorType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_IndicatorOption> createState() => _IndicatorOptionState();
}

class _IndicatorOptionState extends State<_IndicatorOption> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.careSyncColors;
    final style = indicatorStyle(context, widget.type);
    final borderColor = widget.selected
        ? colors.success
        : _pressed
        ? colors.success.withValues(alpha: 0.5)
        : colors.border;

    return Semantics(
      button: true,
      selected: widget.selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14), // 16px menos a borda de 2px.
          decoration: BoxDecoration(
            color: widget.selected
                ? colors.success.withValues(alpha: 0.05)
                : colors.success.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(AppRadius.item),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LucideIcon(style.icon, size: 24, color: style.color),
              const SizedBox(height: 8),
              Text(
                widget.type.label,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  size: 12,
                  lineHeight: 16,
                  color: colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
