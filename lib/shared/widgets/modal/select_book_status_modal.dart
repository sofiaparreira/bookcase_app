import 'package:bookcase/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SelectBookStatusModal extends StatefulWidget {
  const SelectBookStatusModal({super.key});

  @override
  State<SelectBookStatusModal> createState() => _SelectBookStatusModalState();
}

class _SelectBookStatusModalState extends State<SelectBookStatusModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SelectBookStatusButton(
              text: "Lendo",
              icon: Icon(LucideIcons.bookOpen),
              onPressed: () {},
            ),
            _SelectBookStatusButton(
              text: "Lido",
              icon: Icon(LucideIcons.bookCheck),
              onPressed: () {},
            ),
            _SelectBookStatusButton(
              text: "Quero Ler",
              icon: Icon(LucideIcons.bookmarkPlus),
              onPressed: () {},
              showBottomBorder: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectBookStatusButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Widget icon;
  final bool showBottomBorder;

  const new({
    required this.onPressed,
    required this.text,
    required this.icon,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: AppColors.cardSurface,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: showBottomBorder
              ? const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 235, 235, 235),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
