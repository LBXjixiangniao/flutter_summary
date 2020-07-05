extension StringExtension on String {
  bool get isNotNullAndEmpty => !isNullOrEmpty;
  bool get isNullOrEmpty => this == null || this.isEmpty;
  int get notNullLength => this == null ? 0 : this.length;
}
