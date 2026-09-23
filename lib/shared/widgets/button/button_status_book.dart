import 'package:bookcase/core/theme/app_colors.dart';
import 'package:bookcase/core/theme/app_decorations.dart';
import 'package:bookcase/core/theme/app_shadow.dart';
import 'package:flutter/material.dart';

class ButtonStatusBook extends StatefulWidget {
  final String text;
  final Widget? prefixIcon;
  final int quantity;
  final bool selected;
  final VoidCallback onPressed;


  const ButtonStatusBook({
    super.key,
    required this.text,
    required this.quantity,
    required this.selected,
    required this.onPressed,
    this.prefixIcon
  });

  @override
  State<ButtonStatusBook> createState() => _ButtonStatusBookState();
}

class _ButtonStatusBookState extends State<ButtonStatusBook> {
  @override
  Widget build(BuildContext context) {
  return Container(
    height: 40,
    decoration: AppDecorations.button,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.selected ? AppColors.primary : Colors.transparent,

        foregroundColor:
            widget.selected ? Colors.white : AppColors.textPrimary,

        elevation: 0,
        shadowColor: Colors.transparent,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.prefixIcon != null)
            IconTheme(data: IconThemeData(color: widget.selected ? Colors.white : AppColors.primary, size: 20), child: widget.prefixIcon!),

          Text(widget.text, style: TextStyle(fontWeight: FontWeight.w500),),
          CircleAvatar(
            backgroundColor: widget.selected
                ? AppColors.white15
                : AppColors.cream,
            radius: 11,
            child: Text(
              widget.quantity.toString(),
              style: TextStyle(
                color: AppColors.primary
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}