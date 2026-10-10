// Tela: Metas (lista)
// Integrante: Joao vitor kadus
import 'package:flutter/material.dart';

import 'meta_detalhe_screen.dart';
import 'meta_form_screen.dart';

const List<MetaItem> _metas = [
  MetaItem(
    titulo: 'Ler 12 livros em 2026',
    tipo: 'livros',
    atual: 8,
    total: 12,
    prazo: '31/12/2026',
  ),
  MetaItem(
    titulo: '3.000 páginas no semestre',
    tipo: 'páginas',
    atual: 1450,
    total: 3000,
    prazo: '30/11/2026',
  ),
  MetaItem(
    titulo: 'Clássicos brasileiros',
    tipo: 'livros',
    atual: 1,
    total: 5,
    prazo: '31/01/2027',
  ),
  MetaItem(
    titulo: '500 páginas em outubro',
    tipo: 'páginas',
    atual: 500,
    total: 500,
    prazo: '31/10/2026',
  ),
];

class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  static const double _bottomNavigationSpace = 76;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas metas')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          12,
          12,
          12,
          _bottomNavigationSpace + 80,
        ),
        itemCount: _metas.length,
        itemBuilder: (context, i) {
          final meta = _metas[i];
          return Card(
            child: ListTile(
              leading: Icon(
                meta.tipo == 'livros' ? Icons.menu_book : Icons.description,
                color: Colors.teal,
              ),
              title: Text(meta.titulo),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: meta.progresso),
                    const SizedBox(height: 4),
                    Text(
                      '${meta.atual} de ${meta.total} ${meta.tipo} • até ${meta.prazo}',
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MetaDetalheScreen(meta: meta),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: _bottomNavigationSpace),
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Nova meta'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MetaFormScreen()),
            );
          },
        ),
      ),
    );
  }
}
