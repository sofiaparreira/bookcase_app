import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:bookcase/shared/widgets/badge_default.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:flutter/material.dart';

class ReadingCard extends StatefulWidget {

  final String title;
  final String author;
  final int currentPage;
  final int numPages;
  final double progress;
  final int progressPercent;

  const ReadingCard({
    super.key,
    required this.title,
    required this.author,
    required this.currentPage,
    required this.numPages,
    required this.progress,
    required this.progressPercent
    });


  @override
  State<ReadingCard> createState() => _ReadingCardState();
}

class _ReadingCardState extends State<ReadingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: AppDecorations.card,
      
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 24,
            children: [
              // IMAGEM
              const SizedBox(width: 100, child: Text('Imagem')),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    BadgeDefault(text: 'Teste'),

                    TitleCard(text: widget.title),

                    const Text('Patric Roufhfuss'),
                    
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pág. ${widget.currentPage} de ${widget.numPages}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                        Text('${widget.progressPercent}%', style: TextStyle(fontSize: 12)),
                      ],
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: widget.progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    ButtonDefault(
                      text: 'Atualizar progresso',
                      size: ButtonSize.sm,
                      width: ButtonWidth.fit,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        
      ),
    );
  }
}
