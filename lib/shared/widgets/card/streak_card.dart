import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  static const List<String> weekDayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  final List<bool> completedDays;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Row(
            spacing: 8,
            children: [
              const Icon(
                Icons.local_fire_department_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
              Text(
                streakDays == 1
                    ? '1 dia de streak'
                    : '$streakDays dias de streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: List.generate(7, (index) {
              return Expanded(
                child: _StreakDay(
                  label: weekDayLabels[index],
                  completed:
                      index < completedDays.length && completedDays[index],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StreakDay extends StatelessWidget {
  final String label;
  final bool completed;

  const _StreakDay({required this.label, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      children: [
        Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completed ? AppColors.secondary : AppColors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: completed
              ? const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(150, 255, 255, 255),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
