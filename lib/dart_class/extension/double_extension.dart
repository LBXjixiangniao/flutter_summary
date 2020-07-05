extension DoubleExtension on int {
  static double parse(dynamic value) {
    try {
      if (value is double) {
        return value;
      } else if (value is int) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
