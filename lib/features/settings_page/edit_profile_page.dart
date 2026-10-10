// Tela feita por: Maria Luiza Bertolino Matos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  late final TextEditingController _nameController;

  static final _invalidCharRegex = RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ ]');

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _authService.currentUser?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (_invalidCharRegex.hasMatch(name)) {
      return 'Use apenas letras, sem números ou caracteres especiais';
    }
    if (name.contains(RegExp(r'\s{2,}'))) {
      return 'Use apenas um espaço entre as palavras';
    }

    if (!_submitted) return null;

    if (name.isEmpty) {
      return 'Informe seu nome';
    }
    if (name.length < 2) {
      return 'O nome deve ter no mínimo 2 letras';
    }
    return null;
  }

  Future<void> _handleSave() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Salvar alterações',
      message: 'Deseja realmente alterar seu nome?',
      confirmText: 'Salvar',
    );

    if (!confirmed || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Editar perfil',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 24,
            children: [
              TextFieldDefault(
                label: 'Nome',
                controller: _nameController,
                hintText: 'Seu nome',
                keyboardType: TextInputType.name,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                prefixIcon: const Icon(
                  LucideIcons.user,
                  size: 18,
                  color: AppColors.rose,
                ),
                validator: _validateName,
              ),
              ButtonDefault(
                text: 'Salvar alterações',
                onPressed: _handleSave,
                width: ButtonWidth.full,
                size: ButtonSize.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
