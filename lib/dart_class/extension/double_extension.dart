extension DoubleExtension on int {
  static double parse(dynamic value) {
    try {
      if (value is double) {
        return value;
      } else if (value is int) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
