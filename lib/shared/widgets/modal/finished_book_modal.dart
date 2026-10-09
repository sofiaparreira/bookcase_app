import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';

class FinishedBookModal extends StatefulWidget {
  const new({super.key});

  @override
  State<FinishedBookModal> createState() => _FinishedBookModalState();
}

class _FinishedBookModalState extends State<FinishedBookModal> {
  int rating = 0;
  final dateFinished = TextEditingController();

  Future<void> selectDate(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),

      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6F1641),
              onPrimary: Colors.white,
              onSurface: Color(0xFF252525),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.primary,
              headerForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              todayBorder: BorderSide(color: Color(0xFF6F1641)),
              cancelButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.primary),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: AppDecorations.buttonBorderRadius,
                  ),
                ),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(AppColors.primary),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: AppDecorations.buttonBorderRadius,
                  ),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      dateFinished.text =
          "${selectedDate.day.toString().padLeft(2, '0')}/"
          "${selectedDate.month.toString().padLeft(2, '0')}/"
          "${selectedDate.year}";
    }
  }

  @override
  void dispose() {
    dateFinished.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador superior
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              const TitleH2(text: "Finalizar leitura"),

              const SizedBox(height: 8),

              const Text(
                "Registre sua experiência com o livro",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 28),

              _bookInfo(),

              const SizedBox(height: 32),

              const Text(
                "Como foi sua leitura?",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 12),

              _ratingStars(),

              const SizedBox(height: 8),

              Text(
                rating == 0
                    ? "Selecione uma avaliação"
                    : "$rating de 5 estrelas",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 32),

              TextFieldDefault(
                label: "Data de conclusão da leitura",
                controller: dateFinished,
                readOnly: true,
                onTap: () => selectDate(context),
              ),

              const SizedBox(height: 24),

              ButtonDefault(
                text: "Confirmar leitura",
                onPressed: () {},
                width: ButtonWidth.full,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://m.media-amazon.com/images/I/816Udvs9O7L._AC_UF1000,1000_QL80_.jpg",
              width: 64,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 16),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Título do livro",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Autor",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  "120 páginas · Romance",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isSelected = index < rating;

        return IconButton(
          style: IconButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: AppDecorations.buttonBorderRadius,
            ),
          ),
          onPressed: () {
            setState(() {
              rating = index + 1;
            });
          },
          icon: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: isSelected ? const Color(0xFFD1904C) : Colors.grey.shade400,
            size: 34,
          ),
        );
      }),
    );
  }
}
