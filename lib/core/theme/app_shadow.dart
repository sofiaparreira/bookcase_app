import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 6,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
}