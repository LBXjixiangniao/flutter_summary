extension IntExtension on int {
  static int parse(dynamic value) {
    try {
      if (value is int) {
        return value;
      } else if (value is double) {
        return value.toInt();
      } else if (value is String) {
        return int.parse(value);
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
