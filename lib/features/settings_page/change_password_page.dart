// Tela feita por: Maria Luiza Bertolino Matos

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/shared/widgets/button/button_default.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:bookcase/shared/widgets/text_field/text_field_default.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Alterar senha',
      message: 'Deseja realmente alterar sua senha?',
      confirmText: 'Salvar',
    );

    if (!confirmed || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso!')),
    );
    Navigator.pop(context);
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFieldDefault(
      label: label,
      controller: controller,
      obscureText: obscure,
      hintText: '••••••',
      prefixIcon: const Icon(LucideIcons.lock, size: 18, color: AppColors.rose),
      suffixIcon: IconButton(
        onPressed: onToggle,
        tooltip: obscure ? 'Mostrar senha' : 'Ocultar senha',
        icon: Icon(
          obscure ? LucideIcons.eye : LucideIcons.eyeOff,
          size: 18,
          color: AppColors.textTertiary,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Alterar senha',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _buildPasswordField(
                label: 'Senha atual',
                controller: _currentController,
                obscure: _obscureCurrent,
                onToggle: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe sua senha atual';
                  }
                  return null;
                },
              ),
              _buildPasswordField(
                label: 'Nova senha',
                controller: _newController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a nova senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter no mínimo 6 caracteres';
                  }
                  if (value == _currentController.text) {
                    return 'A nova senha deve ser diferente da atual';
                  }
                  return null;
                },
              ),
              _buildPasswordField(
                label: 'Confirmar nova senha',
                controller: _confirmController,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme a nova senha';
                  }
                  if (value != _newController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              ButtonDefault(
                text: 'Salvar nova senha',
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
