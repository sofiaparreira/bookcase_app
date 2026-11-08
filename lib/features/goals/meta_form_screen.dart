// Feito por: João e Sofia Parreira Passos

import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:bookcase/shared/service/book_service.dart';
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
  List<Book> _books = [];
  bool _loadingBooks = true;
  String? _booksError;
  int? _bookId;
  late DateTime _start;
  late DateTime _end;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _tituloCtrl = TextEditingController(text: g?.title ?? '');
    _totalCtrl = TextEditingController(text: g?.targetPages.toString() ?? '');
    _atualCtrl = TextEditingController(text: (g?.currentPage ?? 0).toString());
    _bookId = g?.bookId;
    _start = g?.startDate ?? DateTime.now();
    _end = g?.endDate ?? DateTime.now().add(const Duration(days: 30));
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await BookStatusService().getBooksForCurrentUser();
      if (!mounted) return;
      setState(() {
        _books = books.where((b) => b.databaseId != null).toList();
        if (!_books.any((b) => b.databaseId == _bookId)) _bookId = null;
        _loadingBooks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _booksError = cleanError(e);
        _loadingBooks = false;
      });
    }
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
      bookId: _bookId!,
      targetPages: int.parse(_totalCtrl.text),
      currentPage: int.parse(_atualCtrl.text),
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

  Widget _bookField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Livro da meta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        if (_loadingBooks)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_booksError != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  _booksError!,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _loadingBooks = true;
                    _booksError = null;
                  });
                  _loadBooks();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          )
        else if (_books.isEmpty)
          const Text(
            'Você ainda não tem livros na estante. '
            'Adicione um livro antes de criar uma meta.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          DropdownButtonFormField<int>(
            initialValue: _bookId,
            isExpanded: true,
            hint: const Text('Selecione um livro'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            items: _books
                .map(
                  (b) => DropdownMenuItem<int>(
                    value: b.databaseId,
                    child: Text(b.title, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: _saving ? null : (v) => setState(() => _bookId = v),
            validator: (v) => v == null ? 'Selecione um livro' : null,
          ),
      ],
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
              hintText: 'Ex: Terminar o livro até dezembro',

              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o título da meta'
                  : null,
            ),
            const SizedBox(height: 16),
            _bookField(),
            const SizedBox(height: 16),
            TextFieldDefault(
              controller: _totalCtrl,
              keyboardType: TextInputType.number,
              label: 'Total de páginas da meta',

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
              label: 'Página atual',

              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Informe 0 ou mais';
                final total = int.tryParse(_totalCtrl.text);
                if (total != null && n > total) {
                  return 'Não pode ser maior que o total de páginas';
                }
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
              onPressed: (_saving || _loadingBooks || _books.isEmpty)
                  ? null
                  : _save,
              width: ButtonWidth.full,
            ),
          ],
        ),
      ),
    );
  }
}