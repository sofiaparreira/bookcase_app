import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/badge_default.dart';
import 'package:bookcase/shared/widgets/button_default.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:flutter/material.dart';

class ReadingCard extends StatefulWidget {
  const ReadingCard({super.key});

  @override
  State<ReadingCard> createState() => _ReadingCardState();
}

class _ReadingCardState extends State<ReadingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        elevation: 0,
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

                    TitleCard(text: 'O nome do vento'),

                    const Text('Patric Roufhfuss'),
                    
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pág. 100 de 340',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                          ),
                        ),
                        const Text('32%', style: TextStyle(fontSize: 12)),
                      ],
                    ),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: 0.45,
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
      ),
    );
  }
}
