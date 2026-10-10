// Tela feita por: Maria Luiza Bertolino Matos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/features/auth/login_page.dart';
import 'package:bookcase/features/settings_page/change_password_page.dart';
import 'package:bookcase/features/settings_page/edit_profile_page.dart';
import 'package:bookcase/features/settings_page/info_page.dart';
import 'package:bookcase/shared/widgets/modal/confirm_dialog.dart';
import 'package:bookcase/shared/widgets/modal/rate_app_dialog.dart';
import 'package:bookcase/shared/widgets/sub_page_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = AuthService();

  static const _goalStep = 5;
  static const _goalMin = 5;
  static const _goalMax = 240;

  bool _notifications = true;
  int _dailyGoalMinutes = 30;

  String get _displayName {
    final user = _authService.currentUser;
    if (user == null) return 'Leitor';
    if (user.name.trim().isNotEmpty) return user.name.trim();
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Leitor';
  }

  String get _initials {
    final initials = _authService.currentUser?.initials ?? '';
    return initials.isNotEmpty ? initials : _displayName[0].toUpperCase();
  }

  void _changeDailyGoal(int delta) {
    setState(() {
      _dailyGoalMinutes = (_dailyGoalMinutes + delta).clamp(_goalMin, _goalMax);
    });
  }

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _rateApp() async {
    final rating = await showRateAppDialog(context);
    if (rating == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação enviada. Obrigado!')),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Tem certeza que deseja sair?',
      confirmText: 'Sair',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    _authService.signOut();

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Configurações',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionLabel('Conta'),
            _buildAccountSection(),
            const _SectionLabel('Preferências'),
            _buildPreferencesSection(),
            const _SectionLabel('Aplicativo'),
            _buildAppSection(),
            const SizedBox(height: 24),
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    final email = _authService.currentUser?.email ?? '';

    return _SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 14,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _SettingsTile(
          icon: LucideIcons.user,
          title: 'Editar perfil',
          onTap: () => _openPage(const EditProfilePage()),
        ),
        _SettingsTile(
          icon: LucideIcons.keyRound,
          title: 'Alterar senha',
          onTap: () => _openPage(const ChangePasswordPage()),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: LucideIcons.bell,
          title: 'Notificações',
          subtitle: 'Lembretes diários de leitura',
          trailing: _buildSwitch(
            _notifications,
            (value) => setState(() => _notifications = value),
          ),
        ),
        _SettingsTile(
          icon: LucideIcons.timer,
          title: 'Meta diária',
          subtitle: 'Tempo mínimo por dia',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              _StepperButton(
                icon: LucideIcons.minus,
                backgroundColor: AppColors.cream,
                iconColor: AppColors.primary,
                onPressed: _dailyGoalMinutes > _goalMin
                    ? () => _changeDailyGoal(-_goalStep)
                    : null,
              ),
              SizedBox(
                width: 52,
                child: Text(
                  '${_dailyGoalMinutes}min',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StepperButton(
                icon: LucideIcons.plus,
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
                onPressed: _dailyGoalMinutes < _goalMax
                    ? () => _changeDailyGoal(_goalStep)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return _SettingsCard(
      children: [
        _SettingsTile(
          icon: LucideIcons.info,
          title: 'Sobre o aplicativo',
          onTap: () => _openPage(const InfoPage.about()),
        ),
        _SettingsTile(
          icon: LucideIcons.lock,
          title: 'Política de Privacidade',
          onTap: () => _openPage(const InfoPage.privacy()),
        ),
        _SettingsTile(
          icon: LucideIcons.fileText,
          title: 'Termos de Uso',
          onTap: () => _openPage(const InfoPage.terms()),
        ),
        _SettingsTile(
          icon: LucideIcons.star,
          title: 'Avaliar o app',
          onTap: _rateApp,
        ),
      ],
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.primary,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: AppColors.surfaceBorder,
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _confirmSignOut,
        icon: const Icon(LucideIcons.logOut, size: 16),
        label: const Text('Sair da conta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.rose,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.surfaceBorder,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 18, color: AppColors.rose),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.rose,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 14, color: iconColor),
          ),
        ),
      ),
    );
  }
}
