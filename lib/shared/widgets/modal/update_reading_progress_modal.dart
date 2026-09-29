import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    pageController = TextEditingController(
      text: widget.currentPage?.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                const TitleH2(text: 'Atualizar progresso'),
                const Text("Nome do livro"),
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F4),
                    borderRadius: BorderRadius.circular(11),
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
                _progressTextField(controller: pageController, label: "Página atual"),
                Center(child: const Text("de 551 páginas", style: TextStyle(color: AppColors.primary, fontSize: 14),)),
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
        Text(label, style: TextStyle(
          fontWeight: FontWeight.w600
        ),),
        TextField(
      controller: pageController,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    )
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
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
