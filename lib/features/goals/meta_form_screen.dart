// Feito por: João e Sofia Parreira Passos

import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';

class MetaFormScreen extends StatefulWidget {
  final ReadingGoal? goal;

  const MetaFormScreen({super.key, this.goal});

  @override
  State<MetaFormScreen> createState() => _MetaFormScreenState();
}

class _MetaFormScreenState extends State<MetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GoalsService();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _atualCtrl;
  late DateTime _start;
  late DateTime _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _tituloCtrl = TextEditingController(text: g?.title ?? '');
    _totalCtrl = TextEditingController(text: g?.targetBooks.toString() ?? '');
    _atualCtrl = TextEditingController(text: (g?.currentBooks ?? 0).toString());
    _start = g?.startDate ?? DateTime.now();
    _end = g?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _totalCtrl.dispose();
    _atualCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_end.isBefore(_start)) {
      AppAlert.error(context, 'A data final deve ser depois da inicial.');
      return;
    }

    final goal = ReadingGoal(
      id: widget.goal?.id,
      title: _tituloCtrl.text.trim(),
      targetBooks: int.parse(_totalCtrl.text),
      currentBooks: int.parse(_atualCtrl.text),
      startDate: _start,
      endDate: _end,
    );

    setState(() => _saving = true);
    try {
      if (widget.goal == null) {
        await _service.createGoal(goal);
      } else {
        await _service.updateGoal(goal);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppAlert.error(context, cleanError(e));
    }
  }

  Widget _dateField(String label, DateTime value, bool isStart) {
    return InkWell(
      onTap: _saving ? null : () => _pickDate(isStart: isStart),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatDate(value)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.goal != null;

    return SubPageLayout(
      title: editando ? 'Editar meta' : 'Nova meta',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFieldDefault(
              controller: _tituloCtrl,
              label: 'Título da meta',
              hintText: 'Ex: Ler 12 livros em 2026',

              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o título da meta'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFieldDefault(
              controller: _totalCtrl,
              keyboardType: TextInputType.number,
              label: 'Quantidade de livros (meta)',

              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) {
                  return 'Informe um número maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFieldDefault(
              controller: _atualCtrl,
              keyboardType: TextInputType.number,
              label: 'Livros já lidos',

              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Informe 0 ou mais';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _dateField('Data de início', _start, true),
            const SizedBox(height: 16),
            _dateField('Data final (prazo)', _end, false),
            const SizedBox(height: 24),
            ButtonDefault(
              text: editando ? 'Salvar alterações' : 'Criar meta',
              isLoading: _saving,
              onPressed: _saving ? null : _save,
              width: ButtonWidth.full,
            ),
          ],
        ),
      ),
    );
  }
}
