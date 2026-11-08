// Feito por: João e Sofia Parreira Passos
// Tela: Detalhe da Meta
import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/features/goals/meta_form_screen.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/modal/update_reading_progress_modal.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

class MetaDetalheScreen extends StatefulWidget {
  final ReadingGoal goal;

  const MetaDetalheScreen({super.key, required this.goal});

  @override
  State<MetaDetalheScreen> createState() => _MetaDetalheScreenState();
}

class _MetaDetalheScreenState extends State<MetaDetalheScreen> {
  final _service = GoalsService();
  ReadingGoal get _goal => widget.goal;
  bool _deleting = false;
  bool _savingProgress = false;

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MetaFormScreen(goal: _goal)),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _updateProgress() async {
    final result = await showModalBottomSheet<ReadingProgressResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => UpdateReadingProgressModal(
        title: _goal.bookTitle ?? _goal.title,
        currentPage: _goal.currentPage,
        totalPages: _goal.targetPages,
      ),
    );
    if (result == null || !mounted) return;

    final page = (result.progress * _goal.targetPages).round().clamp(
      0,
      _goal.targetPages,
    );
    if (page == _goal.currentPage) return;

    setState(() => _savingProgress = true);
    try {
      await _service.updateProgress(_goal.id!, page);
      if (!mounted) return;
      AppAlert.success(context, 'Progresso atualizado!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _savingProgress = false);
      AppAlert.error(context, cleanError(e));
    }
  }

  Future<void> _delete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Excluir meta?',
      message: 'Essa ação removerá “${_goal.title}” das suas metas.',
      confirmText: 'Excluir',
      destructive: true,
    );
    if (!confirm || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _service.deleteGoal(_goal.id!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      AppAlert.error(context, cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _goal.progress;
    final percentage = _goal.progressPercent;
    final isComplete = _goal.isCompleted;

    return SubPageLayout(
      title: 'Detalhe da meta',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isComplete
                                    ? AppColors.cream
                                    : AppColors.primary10,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                LucideIcons.bookOpen,
                                size: 25,
                                color: isComplete
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isComplete
                                          ? AppColors.cream
                                          : AppColors.primary10,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isComplete ? 'Concluída' : 'Em andamento',
                                      style: TextStyle(
                                        color: isComplete
                                            ? AppColors.secondary
                                            : AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 9),
                                  Text(
                                    _goal.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Progresso',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Página ${_goal.currentPage} de ${_goal.targetPages}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                color: isComplete
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 11,
                            color: isComplete
                                ? AppColors.secondary
                                : AppColors.primary,
                            backgroundColor: AppColors.surfaceBorder,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: AppDecorations.card,
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: LucideIcons.bookOpen,
                          label: 'Livro',
                          value: _goal.bookTitle ?? 'Livro #${_goal.bookId}',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(
                            height: 1,
                            color: AppColors.surfaceBorder,
                          ),
                        ),
                        _DetailRow(
                          icon: LucideIcons.calendarDays,
                          label: 'Prazo',
                          value: formatDate(_goal.endDate),
                        ),
                        if (_goal.completedAt != null) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(
                              height: 1,
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          _DetailRow(
                            icon: LucideIcons.calendarDays,
                            label: 'Concluída em',
                            value: formatDate(_goal.completedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ButtonDefault(
                    text: 'Atualizar progresso',
                    width: ButtonWidth.full,
                    size: ButtonSize.lg,
                    isLoading: _savingProgress,
                    onPressed: (_deleting || _savingProgress)
                        ? null
                        : _updateProgress,
                  ),
                  const SizedBox(height: 12),
                  Row(
                children: [
                  Expanded(
                    child: ButtonDefault(
                      text: 'Excluir',
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.lg,
                      prefixIcon: const Icon(
                        LucideIcons.trash2,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      isLoading: _deleting,
                      onPressed: _deleting ? null : _delete,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ButtonDefault(
                      text: 'Editar',
                      size: ButtonSize.lg,
                      prefixIcon: const Icon(LucideIcons.pencil, size: 18),
                      onPressed: _deleting ? null : _edit,
                    ),
                  ),
                ],
              ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}