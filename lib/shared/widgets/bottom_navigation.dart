import 'dart:ui';

import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPurple.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.78),
                    AppColors.cardSurface.withValues(alpha: 0.62),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              ),
              child: Row(
                children: [
                  _NavigationItem(
                    icon: LucideIcons.house,
                    label: 'Início',
                    selected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),

                  _NavigationItem(
                    icon: LucideIcons.library,
                    label: 'Estante',
                    selected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),

                  _NavigationItem(
                    icon: LucideIcons.search,
                    label: 'Buscar',
                    selected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),

                  _NavigationItem(
                    icon: LucideIcons.target,
                    label: 'Metas',
                    selected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),

                  _NavigationItem(
                    icon: LucideIcons.user,
                    label: 'Perfil',
                    selected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDecorations.buttonBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.cardSurface,
            borderRadius: AppDecorations.buttonBorderRadius,
          ),
          child: selected
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 2),
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(height: 1),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Icon(icon, size: 21, color: AppColors.textSecondary),
                ),
        ),
      ),
    );
  }
}
