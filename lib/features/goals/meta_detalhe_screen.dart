// Tela: Detalhe da Meta
// Integrante: Joao vitor kadus
import 'package:flutter/material.dart';

import 'meta_form_screen.dart';

class MetaItem {
  final String titulo;
  final String tipo; // 'livros' ou 'páginas'
  final int atual;
  final int total;
  final String prazo;

  const MetaItem({
    required this.titulo,
    required this.tipo,
    required this.atual,
    required this.total,
    required this.prazo,
  });

  double get progresso => atual / total;
}

class MetaDetalheScreen extends StatelessWidget {
  final MetaItem meta;

  const MetaDetalheScreen({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final percentual = (meta.progresso * 100).round();

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
                child: Icon(
                  meta.tipo == 'livros' ? Icons.menu_book : Icons.description,
                  size: 40,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(meta.titulo, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Meta de ${meta.tipo} • prazo até ${meta.prazo}'),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: meta.progresso, minHeight: 10),
            const SizedBox(height: 8),
            Text('${meta.atual} de ${meta.total} ${meta.tipo} ($percentual%)'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MetaFormScreen(meta: meta),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exclusão na próxima etapa'),
                        ),
                      );
                    },
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
