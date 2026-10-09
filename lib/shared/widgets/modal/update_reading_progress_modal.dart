import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/progress/reading_progress_bar.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ProgressType { pages, percentage }

class UpdateReadingProgressModal extends StatefulWidget {
  final int? currentPage;
  final int? totalPages;
  final double? currentPercentage;

  const UpdateReadingProgressModal({
    super.key,
    this.currentPage,
    this.totalPages,
    this.currentPercentage,
  });

  @override
  State<UpdateReadingProgressModal> createState() =>
      _UpdateReadingProgressModalState();
}

class _UpdateReadingProgressModalState
    extends State<UpdateReadingProgressModal> {
  ProgressType selectedType = ProgressType.pages;
  late final TextEditingController pageController;
  late final TextEditingController percentageController;
  int? editedTotalPages;

  int get totalPages => editedTotalPages ?? widget.totalPages ?? 0;

  @override
  void initState() {
    super.initState();
    pageController = TextEditingController(
      text: widget.currentPage?.toString() ?? '',
    );
    percentageController = TextEditingController(
      text: _initialPercentage.round().toString(),
    );
    pageController.addListener(_updateProgress);
    percentageController.addListener(_updateProgress);
  }

  double get _initialPercentage {
    if (widget.currentPercentage != null) {
      final percentage = widget.currentPercentage!;
      return percentage <= 1 ? percentage * 100 : percentage;
    }

    final currentPage = widget.currentPage ?? 0;
    return totalPages > 0 ? currentPage / totalPages * 100 : 0;
  }

  double get _progress {
    if (selectedType == ProgressType.percentage) {
      final percentage = double.tryParse(percentageController.text) ?? 0;
      return percentage / 100;
    }

    final currentPage = double.tryParse(pageController.text) ?? 0;
    return totalPages > 0 ? currentPage / totalPages : 0;
  }

  int get _progressPercent => (_progress * 100).clamp(0, 100).round();

  Future<void> _editTotalPages() async {
    final updatedTotal = await showDialog<int>(
      context: context,
      builder: (context) => _EditTotalPagesDialog(totalPages: totalPages),
    );

    if (updatedTotal == null || !mounted) return;

    setState(() {
      editedTotalPages = updatedTotal;
    });
  }

  void _updateProgress() {
    if (mounted) setState(() {});
  }

  TextEditingController get _selectedController =>
      selectedType == ProgressType.pages
      ? pageController
      : percentageController;

  void _changeProgressBy(int amount) {
    final controller = _selectedController;
    final currentValue = int.tryParse(controller.text) ?? 0;
    final maximumValue = selectedType == ProgressType.percentage
        ? 100
        : totalPages;
    final updatedValue = maximumValue > 0
        ? (currentValue + amount).clamp(0, maximumValue)
        : (currentValue + amount).clamp(0, 999999);

    controller.value = TextEditingValue(
      text: updatedValue.toString(),
      selection: TextSelection.collapsed(
        offset: updatedValue.toString().length,
      ),
    );
  }

  TextEditingValue _limitTypedProgress(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final value = int.tryParse(newValue.text);
    final maximumValue = selectedType == ProgressType.percentage
        ? 100
        : totalPages;

    if (value == null || (maximumValue > 0 && value > maximumValue)) {
      return oldValue;
    }

    return newValue;
  }

  @override
  void dispose() {
    pageController.dispose();
    percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const TitleH2(text: 'Atualizar progresso'),
                const Text("Nome do livro"),
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: AppDecorations.buttonBorderRadius,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _progressButton(
                          text: 'Páginas',
                          type: ProgressType.pages,
                        ),
                      ),
                      Expanded(
                        child: _progressButton(
                          text: 'Porcentagem',
                          type: ProgressType.percentage,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  selectedType == ProgressType.pages
                      ? "Página anterior: ${widget.currentPage ?? 0}"
                      : "Porcentagem anterior: ${_initialPercentage.round()}%",
                ),
                _progressTextField(
                  controller: selectedType == ProgressType.pages
                      ? pageController
                      : percentageController,
                  label: selectedType == ProgressType.pages
                      ? "Página atual"
                      : "Porcentagem atual",
                ),
                Row(
                  children: [
                    Expanded(
                      child: ReadingProgressBar(
                        progress: _progress,
                        semanticLabel: 'Progresso atual da leitura',
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '$_progressPercent%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$totalPages páginas no total",
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        key: const Key('edit-total-pages-button'),
                        tooltip: 'Editar total de páginas',
                        onPressed: _editTotalPages,
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size.square(32),
                          padding: const EdgeInsets.all(6),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppDecorations.buttonBorderRadius,
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 17),
                      ),
                    ],
                  ),
                ),
                ButtonDefault(
                  text: "Salvar",
                  width: ButtonWidth.full,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: AppDecorations.buttonBorderRadius,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Diminuir valor',
                onPressed: () => _changeProgressBy(-1),
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDecorations.buttonBorderRadius,
                  ),
                ),
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: selectedType == ProgressType.percentage ? 48 : 90,
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction(_limitTypedProgress),
                        ],
                        textAlign: selectedType == ProgressType.percentage
                            ? TextAlign.right
                            : TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (selectedType == ProgressType.percentage) ...[
                      const SizedBox(width: 3),
                      const Text(
                        '%',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Aumentar valor',
                onPressed: () => _changeProgressBy(1),
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDecorations.buttonBorderRadius,
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressButton({required String text, required ProgressType type}) {
    final bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.cardSurface,
          borderRadius: AppDecorations.buttonBorderRadius,
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF6F1641)
                : const Color(0xFF9A9A9A),
          ),
        ),
      ),
    );
  }
}

class _EditTotalPagesDialog extends StatefulWidget {
  final int totalPages;

  const _EditTotalPagesDialog({required this.totalPages});

  @override
  State<_EditTotalPagesDialog> createState() => _EditTotalPagesDialogState();
}

class _EditTotalPagesDialogState extends State<_EditTotalPagesDialog> {
  late final TextEditingController controller;
  String? errorText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.totalPages.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() {
    final totalPages = int.tryParse(controller.text);

    if (totalPages == null || totalPages <= 0) {
      setState(() {
        errorText = 'Informe um número de páginas válido.';
      });
      return;
    }

    Navigator.pop(context, totalPages);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar total de páginas'),
      content: TextField(
        key: const Key('total-pages-field'),
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        onSubmitted: (_) => save(),
        decoration: InputDecoration(
          labelText: 'Total de páginas',
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: AppDecorations.buttonBorderRadius,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: AppDecorations.buttonBorderRadius,
            ),
          ),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: save,
          style: TextButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: AppDecorations.buttonBorderRadius,
            ),
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
