// Feito por: João e Sofia Parreira Passos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'meta_detalhe_screen.dart';

class MetaFormScreen extends StatefulWidget {
  final MetaItem? meta;

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
    final meta = widget.meta;
    _tituloCtrl = TextEditingController(text: meta?.titulo ?? '');
    _quantidadeCtrl = TextEditingController(text: meta?.total.toString() ?? '');
    _prazoCtrl = TextEditingController(text: meta?.prazo ?? '');
    _tipo = meta?.tipo ?? 'livros';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _quantidadeCtrl.dispose();
    _prazoCtrl.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return date;
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final selectedDate = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _parseDate(_prazoCtrl.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              surface: AppColors.background,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    _prazoCtrl.text = '$day/$month/${selectedDate.year}';
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meta salva! (API na próxima etapa)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.meta != null;

    return SubPageLayout(
      title: isEditing ? 'Editar meta' : 'Nova meta',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              isEditing ? 'Atualize sua meta' : 'Defina sua próxima conquista',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolha um objetivo claro para acompanhar seu progresso de leitura.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            TextFieldDefault(
              label: 'Título da meta',
              hintText: 'Ex: Ler 12 livros em 2026',
              controller: _tituloCtrl,
              prefixIcon: const Icon(LucideIcons.target, size: 18),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Informe o título da meta'
                  : null,
            ),
            const SizedBox(height: 18),
            _GoalTypeField(
              value: _tipo,
              onChanged: (value) {
                if (value != null) setState(() => _tipo = value);
              },
            ),
            const SizedBox(height: 18),
            TextFieldDefault(
              label: 'Quantidade de $_tipo',
              hintText: _tipo == 'livros' ? 'Ex: 12' : 'Ex: 3000',
              controller: _quantidadeCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icon(
                _tipo == 'livros' ? LucideIcons.bookOpen : LucideIcons.fileText,
                size: 18,
              ),
              validator: (value) {
                final amount = int.tryParse(value ?? '');
                return amount == null || amount <= 0
                    ? 'Informe um número maior que zero'
                    : null;
              },
            ),
            const SizedBox(height: 18),
            TextFieldDefault(
              label: 'Prazo',
              hintText: 'Selecione uma data',
              controller: _prazoCtrl,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: _selectDate,
              prefixIcon: const Icon(LucideIcons.calendarDays, size: 18),
              suffixIcon: const Icon(LucideIcons.chevronDown, size: 18),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o prazo da meta';
                }
                return _parseDate(value) == null
                    ? 'Informe uma data válida'
                    : null;
              },
            ),
            const SizedBox(height: 28),
            ButtonDefault(
              text: isEditing ? 'Salvar alterações' : 'Criar meta',
              width: ButtonWidth.full,
              size: ButtonSize.lg,
              prefixIcon: Icon(
                isEditing ? LucideIcons.check : LucideIcons.plus,
                size: 18,
              ),
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalTypeField extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _GoalTypeField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo da meta',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          icon: const Icon(LucideIcons.chevronDown, size: 18),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(LucideIcons.layers3, size: 18),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'livros', child: Text('Livros')),
            DropdownMenuItem(value: 'páginas', child: Text('Páginas')),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
