import 'dart:collection';

final List<Object> _toStringVisiting = [];
bool _isToStringVisiting(Object o) {
  for (int i = 0; i < _toStringVisiting.length; i++) {
    if (identical(o, _toStringVisiting[i])) return true;
  }
  return false;
}
abstract class CustomMapBase<K, V> extends MapMixin<K, V> {
  static String mapToString(Map<Object, Object> m) {
    // Reuses the list in IterableBase for detecting toString cycles.
    if (_isToStringVisiting(m)) {
      return '{...}';
    }

    var result = StringBuffer();
    try {
      _toStringVisiting.add(m);
      result.write('{');
      bool first = true;
      m.forEach((Object k, Object v) {
        if (!first) {
          result.write(', ');
        }
        first = false;
        result.write(k);
        result.write(': ');
        result.write(v);
      });
      result.write('}');
    } finally {
      assert(identical(_toStringVisiting.last, m));
      _toStringVisiting.removeLast();
    }

    return result.toString();
  }

  static Object _id(Object x) => x;

  /// Fills a [Map] with key/value pairs computed from [iterable].
  ///
  /// This method is used by [Map] classes in the named constructor
  /// `fromIterable`.
  static void fillMapWithMappedIterable(
      Map<Object, Object> map,
      Iterable<Object> iterable,
      Object Function(Object element) key,
      Object Function(Object element) value) {
    key ??= _id;
    value ??= _id;

    if (key == null) throw "!"; // TODO(38493): The `??=` should promote.
    if (value == null) throw "!"; // TODO(38493): The `??=` should promote.

    for (var element in iterable) {
      map[key(element)] = value(element);
    }
  }

  /// Fills a map by associating the [keys] to [values].
  ///
  /// This method is used by [Map] classes in the named constructor
  /// `fromIterables`.
  static void fillMapWithIterables(Map<Object, Object> map,
      Iterable<Object> keys, Iterable<Object> values) {
    Iterator<Object> keyIterator = keys.iterator;
    Iterator<Object> valueIterator = values.iterator;

    bool hasNextKey = keyIterator.moveNext();
    bool hasNextValue = valueIterator.moveNext();

    while (hasNextKey && hasNextValue) {
      map[keyIterator.current] = valueIterator.current;
      hasNextKey = keyIterator.moveNext();
      hasNextValue = valueIterator.moveNext();
    }

    if (hasNextKey || hasNextValue) {
      throw ArgumentError("Iterables do not have same length.");
    }
  }
}