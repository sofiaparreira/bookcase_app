// Tela feita por: Maria Luiza Bertolino Matos
import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/features/auth/auth_service.dart';
import 'package:bookcase/features/my_bookshelf/bookshelf_store.dart';
import 'package:bookcase/features/streak/streak_store.dart';
import 'package:bookcase/models/book.dart';
import 'package:bookcase/features/settings_page/settings_page.dart';
import 'package:bookcase/shared/widgets/text/title_h1.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _bookshelf = BookshelfStore.instance;
  final _streak = StreakStore.instance;

  AuthUser? _user;

  int get _booksRead => _bookshelf.countWithStatus(EnumBookStatus.finished);

  int get _pagesRead => _bookshelf.readPages;

  int get _streakDays => _streak.currentStreak;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _bookshelf.addListener(_onStoreChanged);
    _streak.addListener(_onStoreChanged);
    _loadProfile();
  }

  @override
  void dispose() {
    _bookshelf.removeListener(_onStoreChanged);
    _streak.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() => setState(() {});

  Future<void> _loadProfile() async {
    if (!_authService.isAuthenticated) return;

    try {
      final user = await _authService.fetchCurrentUser();
      if (!mounted) return;
      setState(() => _user = user);
    } catch (_) {}
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (mounted) setState(() => _user = _authService.currentUser ?? _user);
  }

  String get _displayName {
    final user = _user;
    if (user == null) return 'Leitor';
    if (user.name.trim().isNotEmpty) return user.name.trim();
    if (user.email.isNotEmpty) return user.email.split('@').first;
    return 'Leitor';
  }

  String get _initials {
    final initials = _user?.initials ?? '';
    return initials.isNotEmpty ? initials : _displayName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppDecorations.header,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    child: Column(
                      spacing: 16,
                      children: [_buildStatsGrid(), _buildMenu()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        spacing: 24,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: TitleH1(text: 'Perfil', color: Colors.white),
          ),
          Row(
            spacing: 16,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white20,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        const Icon(
                          LucideIcons.flame,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        Text(
                          _streakDays == 1
                              ? '1 dia consecutivo'
                              : '$_streakDays dias consecutivos',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: _StatCard(
                icon: LucideIcons.bookOpen,
                value: '$_booksRead',
                label: 'Livros lidos',
                color: AppColors.primary,
              ),
            ),
            Expanded(
              child: _StatCard(
                icon: LucideIcons.fileText,
                value: '$_pagesRead',
                label: 'Páginas lidas',
                color: AppColors.darkPurple,
              ),
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: _StatCard(
            icon: LucideIcons.flame,
            value: '$_streakDays',
            label: 'Dias de streak',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenu() {
    return Container(
      decoration: AppDecorations.card,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: _MenuTile(
          icon: LucideIcons.settings,
          label: 'Configurações',
          onTap: _openSettings,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          spacing: 12,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
