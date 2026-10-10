import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/models/book.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SelectBookStatusModal extends StatefulWidget {
  final EnumBookStatus? currentStatus;

  const SelectBookStatusModal({super.key, this.currentStatus});

  @override
  State<SelectBookStatusModal> createState() => _SelectBookStatusModalState();
}

class _SelectBookStatusModalState extends State<SelectBookStatusModal> {
  void onPressedStatus(EnumBookStatus status) {
    Navigator.pop(context, status);
  }

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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 12),
            _SelectBookStatusButton(
              text: "Quero ler",
              icon: Icon(LucideIcons.bookmarkPlus),
              selected: widget.currentStatus == EnumBookStatus.want,
              onPressed: () => onPressedStatus(EnumBookStatus.want),
            ),
            _SelectBookStatusButton(
              text: "Lendo",
              icon: Icon(LucideIcons.bookOpen),
              selected: widget.currentStatus == EnumBookStatus.reading,
              onPressed: () => onPressedStatus(EnumBookStatus.reading),
            ),
            _SelectBookStatusButton(
              text: "Lido",
              icon: Icon(LucideIcons.bookCheck),
              selected: widget.currentStatus == EnumBookStatus.finished,
              onPressed: () => onPressedStatus(EnumBookStatus.finished),
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
  final bool selected;

  const new({
    required this.onPressed,
    required this.text,
    required this.icon,
    this.showBottomBorder = true,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: AppColors.cardSurface,
      borderRadius: AppDecorations.buttonBorderRadius,
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: AppDecorations.buttonBorderRadius,
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
            IconTheme.merge(
              data: IconThemeData(
                color: selected ? AppColors.primary : AppColors.textPrimary,
              ),
              child: icon,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(LucideIcons.check, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
