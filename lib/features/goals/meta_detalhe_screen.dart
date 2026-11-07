// Feito por: João e Sofia Parreira Passos
// Tela: Detalhe da Meta
import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/features/goals/meta_form_screen.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:flutter/material.dart';

class MetaDetalheScreen extends StatefulWidget {
  final ReadingGoal goal;

  const MetaDetalheScreen({super.key, required this.goal});

  @override
  State<MetaDetalheScreen> createState() => _MetaDetalheScreenState();
}

class _MetaDetalheScreenState extends State<MetaDetalheScreen> {
  final _service = GoalsService();
  bool _deleting = false;

  Future<void> _edit() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => MetaFormScreen(goal: widget.goal)),
    );
    if (changed == true && mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir meta?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await _service.deleteGoal(widget.goal.id!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(cleanError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da meta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.shade100,
                child: Icon(Icons.menu_book,
                    size: 40, color: Colors.teal.shade800),
              ),
            ),
            const SizedBox(height: 24),
            Text(goal.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'De ${formatDate(goal.startDate)} até ${formatDate(goal.endDate)}',
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: goal.progress, minHeight: 10),
            const SizedBox(height: 8),
            Text(
              '${goal.currentBooks} de ${goal.targetBooks} livros (${goal.progressPercent}%)',
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: _deleting ? null : _edit,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: _deleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    onPressed: _deleting ? null : _delete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}