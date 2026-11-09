// Feito por: Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_actions.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/shopping_list/shopping_list_page.dart';
import 'package:bookcase/features/streak/streak_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/card/metric_card.dart';
import 'package:bookcase/shared/widgets/card/reading_card.dart';
import 'package:bookcase/shared/widgets/card/streak_card.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:bookcase/features/goals/goals_sync.dart';

class DashboardPage extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const DashboardPage({super.key, this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    GoalsSync.instance.start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadSummary();
    });
  }

  Future<void> _loadSummary({bool refresh = false}) async {
    try {
      await BookshelfStore.instance.loadFromApi(refresh: refresh);
    } catch (_) {
      if (mounted) {
        AppAlert.error(
          context,
          'Não foi possível atualizar o resumo. Tente novamente.',
        );
      }
    }
  }

  void _openShoppingList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShoppingListPage(onNavigate: widget.onNavigate),
      ),
    );
  }

  void _openGoals() {
    widget.onNavigate?.call(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // TOPO (PARTE ROXA)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Estante',
                    style: GoogleFonts.dmSerifDisplay(
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () {
                    GoalsService.changes.value++; // força a home recarregar, caso esteja aberta
                    return _loadSummary(refresh: true);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // STREAK DA SEMANA
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: ListenableBuilder(
                            listenable: StreakStore.instance,
                            builder: (context, _) => StreakCard(
                              streakDays: StreakStore.instance.currentStreak,
                              completedDays: StreakStore.instance.weekActivity,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ListenableBuilder(
                            listenable: BookshelfStore.instance,
                            builder: (context, _) {
                              final readingBooks = BookshelfStore.instance
                                  .booksWithStatus(EnumBookStatus.reading);

                              if (readingBooks.isEmpty) {
                                if (BookshelfStore.instance.isLoadingFromApi) {
                                  return const SizedBox(
                                    height: 76,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                return const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 12, 20, 28),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Nenhum livro em andamento',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                );
                              }

                              return _ReadingCarousel(
                                children: readingBooks.map((shelfBook) {
                                  return ReadingCard(
                                    key: ValueKey(shelfBook.book.id),
                                    title: shelfBook.book.title,
                                    author: shelfBook.book.author,
                                    currentPage: shelfBook.currentPage,
                                    totalPages: shelfBook.totalPages,
                                    progress: shelfBook.progress,
                                    progressPercent: shelfBook.progressPercent,
                                    imageUrl: shelfBook.book.image,
                                    onUpdateProgress: () =>
                                        BookshelfActions.editProgress(
                                          context,
                                          shelfBook,
                                        ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 108),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          child: Column(
                            spacing: 20,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TitleH2(text: 'Seu resumo'),
                              ListenableBuilder(
                                listenable: BookshelfStore.instance,
                                builder: (context, _) => Row(
                                  spacing: 12,
                                  children: [
                                    MetricCard(
                                      number: BookshelfStore.instance
                                          .countWithStatus(
                                            EnumBookStatus.finished,
                                          ),
                                      icon: const Icon(Icons.menu_book),
                                      text: 'Livros lidos',
                                      variant: EnumMetricCardVariant.primary,
                                    ),
                                    const MetricCard(
                                      number: 3,
                                      icon: Icon(Icons.emoji_events_outlined),
                                      text: 'Conquistas',
                                      variant: EnumMetricCardVariant.secondary,
                                    ),
                                    const MetricCard(
                                      number: 1552,
                                      icon: Icon(Icons.description_outlined),
                                      text: 'Páginas lidas',
                                      variant: EnumMetricCardVariant.neutral,
                                    ),
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const TitleH2(text: 'Meta atual'),
                                  ButtonDefault(
                                    text: 'Ver metas',
                                    variant: ButtonVariant.transparent,
                                    suffixIcon: const Icon(Icons.chevron_right),
                                    onPressed: _openGoals,
                                  ),
                                ],
                              ),
                              _GoalPreview(onTap: _openGoals),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const TitleH2(text: 'Lista de compras'),
                                  ButtonDefault(
                                    text: 'Ver lista',
                                    variant: ButtonVariant.transparent,
                                    suffixIcon: const Icon(Icons.chevron_right),
                                    onPressed: () => _openShoppingList(context),
                                  ),
                                ],
                              ),
                              _ShoppingListPreview(
                                onTap: () => _openShoppingList(context),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _ReadingCarousel extends StatefulWidget {
  final List<Widget> children;

  const _ReadingCarousel({required this.children});

  @override
  State<_ReadingCarousel> createState() => _ReadingCarouselState();
}

class _ReadingCarouselState extends State<_ReadingCarousel> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width - 40).clamp(
      300.0,
      360.0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth =
            widget.children.length * cardWidth +
            (widget.children.length - 1) * 12 +
            40;
        final overflow = contentWidth - constraints.maxWidth;
        final dotCount = overflow > 0
            ? (overflow / (cardWidth + 12)).ceil() + 1
            : 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: widget.children,
              ),
            ),
            if (dotCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final offset = _controller.hasClients
                        ? _controller.offset
                        : 0.0;
                    final activeDot = ((offset / overflow) * (dotCount - 1))
                        .round()
                        .clamp(0, dotCount - 1);

                    return Semantics(
                      label:
                          'Lendo agora: posição ${activeDot + 1} de $dotCount',
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(dotCount, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == activeDot
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.35),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GoalPreview extends StatefulWidget {
  final VoidCallback onTap;

  const _GoalPreview({required this.onTap});

  @override
  State<_GoalPreview> createState() => _GoalPreviewState();
}

class _GoalPreviewState extends State<_GoalPreview> {
  ReadingGoal? _goal;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    GoalsService.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    GoalsService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final goals = await GoalsService().getGoals();
      // Meta em andamento com o prazo mais próximo; se todas estiverem
      // concluídas, mostra a última da lista.
      final open = goals.where((g) => !g.isCompleted).toList()
        ..sort((a, b) => a.endDate.compareTo(b.endDate));
      final goal = open.isNotEmpty
          ? open.first
          : (goals.isNotEmpty ? goals.last : null);
      if (!mounted) return;
      setState(() {
        _goal = goal;
        _error = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(LucideIcons.target, size: 21, color: AppColors.primary),
    );
  }

  Widget _message(String title, String subtitle) {
    return _card(
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _message('Carregando meta...', 'Aguarde um instante');
    }
    if (_error) {
      return _message(
        'Não foi possível carregar a meta',
        'Toque para abrir suas metas',
      );
    }
    final goal = _goal;
    if (goal == null) {
      return _message(
        'Você ainda não tem metas',
        'Toque para criar sua primeira meta',
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _icon(),
              const SizedBox(width: 12),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${goal.progressPercent}%',
                style: const TextStyle(
                  color: AppColors.primary,
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
              value: goal.progress,
              minHeight: 9,
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceBorder,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingListPreview extends StatelessWidget {
  final VoidCallback onTap;

  const _ShoppingListPreview({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _PreviewHeader(),
                SizedBox(height: 16),
                _PreviewShoppingItem(
                  title: 'A Biblioteca da Meia-Noite',
                  author: 'Matt Haig',
                  price: 'R\$ 44,90',
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.surfaceBorder),
                ),
                _PreviewShoppingItem(
                  title: 'Torto Arado',
                  author: 'Itamar Vieira Junior',
                  price: 'R\$ 52,90',
                  bought: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            LucideIcons.shoppingBag,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Próximas compras',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '1 livro pendente',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          'R\$ 44,90',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PreviewShoppingItem extends StatelessWidget {
  final String title;
  final String author;
  final String price;
  final bool bought;

  const _PreviewShoppingItem({
    required this.title,
    required this.author,
    required this.price,
    this.bought = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bought ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: bought ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Icon(
            bought ? LucideIcons.check : LucideIcons.bookOpen,
            size: 16,
            color: bought ? Colors.white : AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: bought
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  decoration: bought ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
