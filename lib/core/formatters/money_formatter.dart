class MoneyFormatter {
  static String rub(double value) {
    final whole = value.round();
    final digits = whole.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final reverseIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(' ');
      }
    }

    return '$buffer ₽';
  }
}
