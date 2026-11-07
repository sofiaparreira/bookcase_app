// Feito por: João e Sofia Parreira Passos
// Tela: Metas (lista)
import 'package:bookcase/features/goals/goal_utils.dart';
import 'package:bookcase/features/goals/goals_service.dart';
import 'package:bookcase/features/goals/meta_detalhe_screen.dart';
import 'package:bookcase/features/goals/meta_form_screen.dart';
import 'package:bookcase/models/reading_goal.dart';
import 'package:flutter/material.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final _service = GoalsService();
  late Future<List<ReadingGoal>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getGoals();
  }

  void _reload() {
    setState(() {
      _future = _service.getGoals();
    });
  }

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text('Minhas metas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova meta',
            onPressed: () => _open(const MetaFormScreen()),
          ),
        ],
      ),
      body: FutureBuilder<List<ReadingGoal>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cleanError(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          final goals = snapshot.data ?? [];
          if (goals.isEmpty) {
            return const Center(
              child: Text('Você ainda não tem metas.\nToque em "Nova meta".',
                  textAlign: TextAlign.center),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: goals.length,
              itemBuilder: (context, i) {
                final goal = goals[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book, color: Colors.teal),
                    title: Text(goal.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: goal.progress),
                          const SizedBox(height: 4),
                          Text(
                            '${goal.currentBooks} de ${goal.targetBooks} livros • até ${formatDate(goal.endDate)}',
                          ),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(MetaDetalheScreen(goal: goal)),
                  ),
                );
              },
            ),
          );
        },
      ),
            floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nova meta'),
          onPressed: () => _open(const MetaFormScreen()),
        ),
      ),
    );
  }
}