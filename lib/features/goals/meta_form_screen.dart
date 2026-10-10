// Tela: Formulário de Meta (criar/editar)
// Integrante: Joao vitor kadus
import 'package:flutter/material.dart';
import 'meta_detalhe_screen.dart';

class MetaFormScreen extends StatefulWidget {
  final MetaItem? meta; // null = nova meta, preenchido = editar

  const MetaFormScreen({super.key, this.meta});

  @override
  State<MetaFormScreen> createState() => _MetaFormScreenState();
}

class _MetaFormScreenState extends State<MetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _quantidadeCtrl;
  late final TextEditingController _prazoCtrl;
  String _tipo = 'livros';

  @override
  void initState() {
    super.initState();
    final m = widget.meta;
    _tituloCtrl = TextEditingController(text: m?.titulo ?? '');
    _quantidadeCtrl = TextEditingController(text: m?.total.toString() ?? '');
    _prazoCtrl = TextEditingController(text: m?.prazo ?? '');
    _tipo = m?.tipo ?? 'livros';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _quantidadeCtrl.dispose();
    _prazoCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meta salva! (API na próxima etapa)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.meta != null;

    return Scaffold(
      appBar: AppBar(title: Text(editando ? 'Editar meta' : 'Nova meta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título da meta',
                hintText: 'Ex: Ler 12 livros em 2026',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o título da meta'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo da meta',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'livros', child: Text('Livros')),
                DropdownMenuItem(value: 'páginas', child: Text('Páginas')),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Quantidade de $_tipo',
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Informe um número maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prazoCtrl,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                labelText: 'Prazo',
                hintText: 'Ex: 31/12/2026',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Informe o prazo da meta'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvar,
              child: Text(editando ? 'Salvar alterações' : 'Criar meta'),
            ),
          ],
        ),
      ),
    );
  }
}