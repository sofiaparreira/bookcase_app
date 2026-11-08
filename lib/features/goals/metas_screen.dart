// Feito por: João e Sofia Parreira Passos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/features/goals/meta_detalhe_screen.dart';
import 'package:bookcase/features/goals/meta_form_screen.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/button/icon_button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  static const double _bottomNavigationSpace = 92;

  final _service = GoalsService();
  List<ReadingGoal> _goals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final goals = await _service.getGoals();
      if (!mounted) return;
      setState(() {
        _goals = goals;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = cleanError(e);
        _loading = false;
      });
    }
  }

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) _load();
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ButtonDefault(text: 'Tentar novamente', onPressed: _load),
            ],
          ),
        ),
      );
    }

    if (_goals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Você ainda não tem metas.\nToque em + para criar a primeira.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          _bottomNavigationSpace,
        ),
        itemCount: _goals.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return _GoalCard(
            goal: goal,
            onTap: () => _open(MetaDetalheScreen(goal: goal)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedGoals = _goals.where((goal) => goal.isCompleted).length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: TitleH1(
                            text: 'Minhas metas',
                            color: Colors.white,
                          ),
                        ),
                        IconButtonDefault(
                          icon: const Icon(LucideIcons.plus),
                          tooltip: 'Criar nova meta',
                          variant: ButtonVariant.secondary,
                          onPressed: () => _open(const MetaFormScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _loading || _error != null
                          ? ' '
                          : '${_goals.length} metas  •  $completedGoals concluída${completedGoals == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final ReadingGoal goal;
  final VoidCallback onTap;

  const _GoalCard({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isComplete = goal.isCompleted;
    final progress = goal.progress;
    final percentage = goal.progressPercent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppColors.cream
                            : AppColors.primary10,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        LucideIcons.bookOpen,
                        size: 21,
                        color: isComplete
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          if (goal.bookTitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              goal.bookTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendarDays,
                                size: 13,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Até ${formatDate(goal.endDate)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Página ${goal.currentPage} de ${goal.targetPages}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: isComplete
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    color: isComplete ? AppColors.secondary : AppColors.primary,
                    backgroundColor: AppColors.surfaceBorder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}