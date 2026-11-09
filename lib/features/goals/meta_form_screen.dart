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
    _bookId = g?.bookId;
    _start = g?.startDate ?? DateUtils.dateOnly(DateTime.now());
    _end = initialGoalPickerDate(
      selectedDate: g?.endDate ?? _start.add(const Duration(days: 30)),
      isStart: false,
    );
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await BookStatusService().getBooksForCurrentUser();
      if (!mounted) return;
      setState(() {
                _books = books
            .where(
              (b) =>
                  b.databaseId != null &&
                  (b.status == EnumBookStatus.reading ||
                      b.status == EnumBookStatus.finished ||
                      b.databaseId == _bookId),
            )
            .toList();
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
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final selectedDate = isStart ? _start : _end;
    final firstDate = firstSelectableGoalDate(isStart: isStart);
    final today = firstSelectableGoalDate(isStart: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialGoalPickerDate(
        selectedDate: selectedDate,
        isStart: isStart,
      ),
      firstDate: firstDate,
      lastDate: DateTime(2100),
      currentDate: today,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      selectableDayPredicate: isStart
          ? null
          : (date) => isSelectableGoalEndDate(date, now: today),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.background,
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    if (!isStart && !isSelectableGoalEndDate(picked, now: today)) {
      AppAlert.error(context, 'Selecione hoje ou uma data futura.');
      return;
    }
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Book? get _selectedBook {
    for (final book in _books) {
      if (book.databaseId == _bookId) return book;
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isSelectableGoalEndDate(_end)) {
      AppAlert.error(context, 'A data final não pode ser anterior a hoje.');
      return;
    }
    if (_end.isBefore(_start)) {
      AppAlert.error(context, 'A data final deve ser depois da inicial.');
      return;
    }

    final selectedBook = _selectedBook;
    if (selectedBook == null) {
      AppAlert.error(context, 'Selecione um livro válido para a meta.');
      return;
    }

    final targetPages = int.parse(_totalCtrl.text);

    final goal = ReadingGoal(
      id: widget.goal?.id,
      title: _tituloCtrl.text.trim(),
      bookId: _bookId!,
      targetPages: targetPages,
      currentPage: currentPageForGoal(
        book: selectedBook,
        targetPages: targetPages,
      ),
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

  Widget _dateField({
    required String label,
    required DateTime value,
    required bool isStart,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: _saving ? null : () => _pickDate(isStart: isStart),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: border,
              enabledBorder: border,
              suffixIcon: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            child: Text(
              formatDate(value),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
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
            'Você ainda não tem livros lidos ou em leitura. '
            'Marque um livro como "Lendo" ou "Lido" na estante antes de criar uma meta.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          DropdownButtonFormField<int>(
            initialValue: _bookId,
            isExpanded: true,
            hint: const Text('Selecione um livro'),
            dropdownColor: AppColors.background,
            borderRadius: BorderRadius.circular(18),
            elevation: 6,
            menuMaxHeight: 320,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
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
            selectedItemBuilder: (context) => _books
                .map(
                  (book) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
                .toList(),
            items: _books
                .map(
                  (book) => DropdownMenuItem<int>(
                    value: book.databaseId,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: book.databaseId == _bookId
                            ? AppColors.primary10
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (book.author.trim().isNotEmpty)
                                  Text(
                                    book.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (book.databaseId == _bookId)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
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
            _dateField(label: 'Data de início', value: _start, isStart: true),
            const SizedBox(height: 16),
            _dateField(
              label: 'Data final (prazo)',
              value: _end,
              isStart: false,
            ),
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
