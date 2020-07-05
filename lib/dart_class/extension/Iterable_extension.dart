extension IterableExtension<E> on Iterable<E> {
  bool get isNotNullAndEmpty {
    if (this == null) {
      return false;
    } else {
      return isNotEmpty;
    }
  }

  E get firstOrNull => isNotNullAndEmpty ? first : null;

  int get notNulllength => this == null ? 0 : length;
}

extension MapExtension<K, V> on Map<K, V> {
  bool get isNotNullAndEmpty {
    if (this == null) {
      return false;
    } else {
      return isNotEmpty;
    }
  }

  int get notNulllength => this == null ? 0 : length;
}
