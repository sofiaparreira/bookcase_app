import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/badge_default.dart';
import 'package:bookcase/shared/widgets/button_default.dart';
import 'package:bookcase/shared/widgets/card/reading_card.dart';
import 'package:bookcase/shared/widgets/title_card.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const daysOfWeek = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Olá',
                        style: TextStyle(
                          color: Color.fromARGB(180, 255, 255, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const TitleH1(text: 'Ana', color: Colors.white),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(26, 255, 255, 255),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          spacing: 6,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.local_fire_department, color: AppColors.secondary,),
                                const Text('7 dias de streak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),)
                              ],
                            ),
                            Row(
                              children: daysOfWeek.map((day) {
                                return  Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 44,
                                        child: Card(
                                          color: AppColors.secondary,
                                          child: const Center(child: Icon(Icons.check_circle_outline, color: Colors.white, size: 22,)),
                                        ),
                                      ),
                                      Text(day, style: TextStyle(color: const Color.fromARGB(187, 255, 255, 255), fontWeight: FontWeight.w200, fontSize: 11))
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 15,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TitleH2(text: 'Lendo agora'),
                          ButtonDefault(text: 'Ver estante', variant: ButtonVariant.transparent, suffixIcon: Icon(Icons.chevron_right),onPressed: () {}),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(spacing:12, children: [ReadingCard(), ReadingCard()],),
                      )
                    ],

                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
