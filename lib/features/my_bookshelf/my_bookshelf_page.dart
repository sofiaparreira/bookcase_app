import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/button/button_status_book.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text_field/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyBookshelfPage extends StatefulWidget {
  const MyBookshelfPage({super.key});

  @override
  State<MyBookshelfPage> createState() => _MyBookshelfPageState();
}

class _MyBookshelfPageState extends State<MyBookshelfPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  spacing: 12,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TitleH1(
                          text: "Minha Estante",
                          color: Colors.white,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.plus),
                          color: Colors.white,
                          iconSize: 20,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white10,
                          ),
                        ),
                      ],
                    ),

                    SearchTextField(
                      label: "Buscar livros...",
                      controller: searchController,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: ButtonStatusBook(
                                  text: 'Lendo',
                                  quantity: 2,
                                  prefixIcon: Icon(
                                    LucideIcons.bookOpen,
                                  ),
                                  selected: true,
                                  onPressed: () {},
                                ),
                              ),
                              Expanded(
                                child: ButtonStatusBook(
                                  text: 'Lendo',
                                  quantity: 2,
                                  prefixIcon: Icon(
                                    LucideIcons.bookBookmark,
                                  ),
                                  selected: false,
                                  onPressed: () {},
                                ),
                              ),
                              Expanded(
                                child: ButtonStatusBook(
                                  text: 'Lendo',
                                  quantity: 2,
                                  prefixIcon: Icon(
                                    LucideIcons.circleCheck,
                                  ),
                                  selected: false,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
