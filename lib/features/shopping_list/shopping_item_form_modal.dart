import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/features/shopping_list/price_utils.dart';
import 'package:bookcase/models/shopping_list_item.dart';
import 'package:bookcase/shared/widgets/alerts/app_alert.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/text/title_h2.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Future<bool> showShoppingItemFormModal(
  BuildContext context, {
  required ShoppingListItem initial,
  required Future<void> Function(ShoppingListItem item) onSubmit,
  bool isEditing = false,
  bool showDetails = true,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    builder: (_) => ShoppingItemFormModal(
      initial: initial,
      onSubmit: onSubmit,
      isEditing: isEditing,
      showDetails: showDetails,
    ),
  );
  return saved ?? false;
}

class ShoppingItemFormModal extends StatefulWidget {
  final ShoppingListItem initial;
  final Future<void> Function(ShoppingListItem item) onSubmit;
  final bool isEditing;

  final bool showDetails;

  const ShoppingItemFormModal({
    super.key,
    required this.initial,
    required this.onSubmit,
    this.isEditing = false,
    this.showDetails = true,
  });

  @override
  State<ShoppingItemFormModal> createState() => _ShoppingItemFormModalState();
}

class _ShoppingItemFormModalState extends State<ShoppingItemFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _priceCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initial.title);
    _authorCtrl = TextEditingController(text: widget.initial.author ?? '');
    _priceCtrl = TextEditingController(
      text: widget.initial.price > 0
          ? formatPriceValue(widget.initial.price)
          : '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final author = _authorCtrl.text.trim();
    final item = ShoppingListItem(
      id: widget.initial.id,
      title: _titleCtrl.text.trim(),
      author: author.isEmpty ? null : author,
      price: parsePrice(_priceCtrl.text),
      bought: widget.initial.bought,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(item);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      AppAlert.error(context, 'Erro ao salvar: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = widget.showDetails
        ? (widget.isEditing
              ? 'Atualize as informações deste livro.'
              : 'Salve um livro que você quer comprar depois.')
        : widget.initial.title;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      TitleH2(
                        text: widget.isEditing
                            ? 'Editar livro'
                            : 'Adicionar à lista',
                      ),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (widget.showDetails) ...[
                    TextFieldDefault(
                      label: 'Título',
                      hintText: 'Nome do livro',
                      controller: _titleCtrl,
                      prefixIcon: const Icon(LucideIcons.bookOpen, size: 18),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Informe o título do livro'
                          : null,
                    ),
                    TextFieldDefault(
                      label: 'Autor (opcional)',
                      hintText: 'Nome do autor',
                      controller: _authorCtrl,
                      prefixIcon: const Icon(LucideIcons.userRound, size: 18),
                    ),
                  ],
                  TextFieldDefault(
                    label: 'Preço',
                    hintText: '0,00',
                    controller: _priceCtrl,
                    autofocus: !widget.showDetails,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyInputFormatter()],
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 16, right: 8),
                      child: Text(
                        'R\$',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    validator: (value) =>
                        parsePrice(value ?? '') > maxShoppingPrice
                        ? 'O preço máximo é ${formatPrice(maxShoppingPrice)}'
                        : null,
                  ),
                  Text(
                    'Valor máximo: ${formatPrice(maxShoppingPrice)}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  ButtonDefault(
                    text: widget.isEditing
                        ? 'Salvar alterações'
                        : 'Adicionar livro',
                    width: ButtonWidth.full,
                    isLoading: _isSaving,
                    prefixIcon: Icon(
                      widget.isEditing ? LucideIcons.check : LucideIcons.plus,
                      size: 18,
                    ),
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
