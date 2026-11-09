import 'package:flutter/services.dart';

const double maxShoppingPrice = 10000;

String formatPriceValue(double price) {
  final cents = (price * 100).round();
  final integer = (cents ~/ 100).toString();
  final decimals = (cents % 100).toString().padLeft(2, '0');

  final buffer = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) buffer.write('.');
    buffer.write(integer[i]);
  }
  return '$buffer,$decimals';
}

String formatPrice(double price) => 'R\$ ${formatPriceValue(price)}';

double parsePrice(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return 0;
  return int.parse(digits) / 100;
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final value = int.parse(digits) / 100;
    if (value > maxShoppingPrice) return oldValue;

    final text = formatPriceValue(value);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
