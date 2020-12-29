// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection' hide SplayTreeSet;
import 'dart:html';

import 'package:flutter/material.dart';

typedef _Predicate<T> = bool Function(T value);

/// A node in a splay tree. It holds the sorting key and the left
/// and right children in the tree.
class _SplayTreeNode<K, Node extends _SplayTreeNode<K, Node>> {
  final K key;

  Node left;
  Node right;

  _SplayTreeNode(this.key);
}

/// A node in a splay tree based set.
class _SplayTreeSetNode<K> extends _SplayTreeNode<K, _SplayTreeSetNode<K>> {
  _SplayTreeSetNode(K key) : super(key);
}

/// A splay tree is a self-balancing binary search tree.
///
/// It has the additional property that recently accessed elements
/// are quick to access again.
/// It performs basic operations such as insertion, look-up and
/// removal, in O(log(n)) amortized time.
abstract class _SplayTree<K, Node extends _SplayTreeNode<K, Node>> {
  // The root node of the splay tree. It will contain either the last
  // element inserted or the last element looked up.
  Node get _root;
  set _root(Node newValue);

  // Number of elements in the splay tree.
  int _count = 0;

  /// Counter incremented whenever the keys in the map changes.
  ///
  /// Used to detect concurrent modifications.
  int _modificationCount = 0;

  /// Counter incremented whenever the tree structure changes.
  ///
  /// Used to detect that an in-place traversal cannot use
  /// cached information that relies on the tree structure.
  int _splayCount = 0;

  /// The comparator that is used for this splay tree.
  Comparator<K> get _compare;

  /// The predicate to determine that a given object is a valid key.
  _Predicate get _validKey;

  /// Perform the splay operation for the given key. Moves the node with
  /// the given key to the top of the tree.  If no node has the given
  /// key, the last node on the search path is moved to the top of the
  /// tree. This is the simplified top-down splaying algorithm from:
  /// "Self-adjusting Binary Search Trees" by Sleator and Tarjan.
  ///
  /// Returns the result of comparing the new root of the tree to [key].
  /// Returns -1 if the table is empty.
  int _splay(K key) {
    if (_root == null) return -1;

    // The right and newTreeRight variables start out null, and are set
    // after the first move left.  The right node is the destination
    // for subsequent left rebalances, and newTreeRight holds the left
    // child of the final tree.  The newTreeRight variable is set at most
    // once, after the first move left, and is null iff right is null.
    // The left and newTreeLeft variables play the corresponding role for
    // right rebalances.
    Node right;
    Node newTreeRight;
    Node left;
    Node newTreeLeft;
    var current = _root;
    // Hoist the field read out of the loop.
    var compare = _compare;
    int comp;
    while (true) {
      comp = compare(current.key, key);
      if (comp > 0) {
        var currentLeft = current.left;
        if (currentLeft == null) break;
        comp = compare(currentLeft.key, key);
        if (comp > 0) {
          // Rotate right.
          current.left = currentLeft.right;
          currentLeft.right = current;
          current = currentLeft;
          currentLeft = current.left;
          if (currentLeft == null) break;
        }
        // Link right.
        if (right == null) {
          // First left rebalance, store the eventual right child
          newTreeRight = current;
        } else {
          right.left = current;
        }
        right = current;
        current = currentLeft;
      } else if (comp < 0) {
        var currentRight = current.right;
        if (currentRight == null) break;
        comp = compare(currentRight.key, key);
        if (comp < 0) {
          // Rotate left.
          current.right = currentRight.left;
          currentRight.left = current;
          current = currentRight;
          currentRight = current.right;
          if (currentRight == null) break;
        }
        // Link left.
        if (left == null) {
          // First right rebalance, store the eventual left child
          newTreeLeft = current;
        } else {
          left.right = current;
        }
        left = current;
        current = currentRight;
      } else {
        break;
      }
    }
    // Assemble.
    if (left != null) {
      left.right = current.left;
      current.left = newTreeLeft;
    }
    if (right != null) {
      right.left = current.right;
      current.right = newTreeRight;
    }
    _root = current;

    _splayCount++;
    return comp;
  }

  // Emulates splaying with a key that is smaller than any in the subtree
  // anchored at [node].
  // and that node is returned. It should replace the reference to [node]
  // in any parent tree or root pointer.
  Node _splayMin(Node node) {
    var current = node;
    var nextLeft = current.left;
    while (nextLeft != null) {
      var left = nextLeft;
      current.left = left.right;
      left.right = current;
      current = left;
      nextLeft = current.left;
    }
    return current;
  }

  // Emulates splaying with a key that is greater than any in the subtree
  // anchored at [node].
  // After this, the largest element in the tree is the root of the subtree,
  // and that node is returned. It should replace the reference to [node]
  // in any parent tree or root pointer.
  Node _splayMax(Node node) {
    var current = node;
    var nextRight = current.right;
    while (nextRight != null) {
      var right = nextRight;
      current.right = right.left;
      right.left = current;
      current = right;
      nextRight = current.right;
    }
    return current;
  }

  Node _remove(K key) {
    if (_root == null) return null;
    int comp = _splay(key);
    if (comp != 0) return null;
    var root = _root;
    var result = root;
    var left = root.left;
    _count--;
    // assert(_count >= 0);
    if (left == null) {
      _root = root.right;
    } else {
      var right = root.right;
      // Splay to make sure that the new root has an empty right child.
      root = _splayMax(left);

      // Insert the original right child as the right child of the new
      // root.
      root.right = right;
      _root = root;
    }
    _modificationCount++;
    return result;
  }

  /// Adds a new root node with the given [key] or [value].
  ///
  /// The [comp] value is the result of comparing the existing root's key
  /// with key.
  void _addNewRoot(Node node, int comp) {
    _count++;
    _modificationCount++;
    var root = _root;
    if (root == null) {
      _root = node;
      return;
    }
    // assert(_count >= 0);
    if (comp < 0) {
      node.left = root;
      node.right = root.right;
      root.right = null;
    } else {
      node.right = root;
      node.left = root.left;
      root.left = null;
    }
    _root = node;
  }

  Node get _first {
    var root = _root;
    if (root == null) return null;
    _root = _splayMin(root);
    return _root;
  }

  Node get _last {
    var root = _root;
    if (root == null) return null;
    _root = _splayMax(root);
    return _root;
  }

  void _clear() {
    _root = null;
    _count = 0;
    _modificationCount++;
  }
}

int _dynamicCompare(dynamic a, dynamic b) => Comparable.compare(a, b);

Comparator<K> _defaultCompare<K>() {
  // If K <: Comparable, then we can just use Comparable.compare
  // with no casts.
  Object compare = Comparable.compare;
  if (compare is Comparator<K>) {
    return compare;
  }
  // Otherwise wrap and cast the arguments on each call.
  return _dynamicCompare;
}

/// A [Set] of objects that can be ordered relative to each other.
///
/// The set is based on a self-balancing binary tree. It allows most operations
/// in amortized logarithmic time.
///
/// Elements of the set are compared using the `compare` function passed in
/// the constructor, both for ordering and for equality.
/// If the set contains only an object `a`, then `set.contains(b)`
/// will return `true` if and only if `compare(a, b) == 0`,
/// and the value of `a == b` is not even checked.
/// If the compare function is omitted, the objects are assumed to be
/// [Comparable], and are compared using their [Comparable.compareTo] method.
/// Non-comparable objects (including `null`) will not work as an element
/// in that case.
class SplayTreeSet<E> extends _SplayTree<E, _SplayTreeSetNode<E>> with IterableMixin<E>, SetMixin<E> {
  _SplayTreeSetNode<E> _root;

  Comparator<E> _compare;
  _Predicate _validKey;

  /// Create a new [SplayTreeSet] with the given compare function.
  ///
  /// If the [compare] function is omitted, it defaults to [Comparable.compare],
  /// and the elements must be comparable.
  ///
  /// A provided `compare` function may not work on all objects. It may not even
  /// work on all `E` instances.
  ///
  /// For operations that add elements to the set, the user is supposed to not
  /// pass in objects that doesn't work with the compare function.
  ///
  /// The methods [contains], [remove], [lookup], [removeAll] or [retainAll]
  /// are typed to accept any object(s), and the [isValidKey] test can used to
  /// filter those objects before handing them to the `compare` function.
  ///
  /// If [isValidKey] is provided, only values satisfying `isValidKey(other)`
  /// are compared using the `compare` method in the methods mentioned above.
  /// If the `isValidKey` function returns false for an object, it is assumed to
  /// not be in the set.
  ///
  /// If omitted, the `isValidKey` function defaults to checking against the
  /// type parameter: `other is E`.
  SplayTreeSet([int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey])
      : _compare = compare ?? _defaultCompare<E>(),
        _validKey = isValidKey ?? ((dynamic v) => v is E);

  /// Creates a [SplayTreeSet] that contains all [elements].
  ///
  /// The set works as if created by `new SplayTreeSet<E>(compare, isValidKey)`.
  ///
  /// All the [elements] should be instances of [E] and valid arguments to
  /// [compare].
  /// The `elements` iterable itself may have any element type, so this
  /// constructor can be used to down-cast a `Set`, for example as:
  /// ```dart
  /// Set<SuperType> superSet = ...;
  /// Set<SubType> subSet =
  ///     new SplayTreeSet<SubType>.from(superSet.whereType<SubType>());
  /// ```
  factory SplayTreeSet.from(Iterable elements,
      [int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey]) {
    if (elements is Iterable<E>) {
      return SplayTreeSet<E>.of(elements, compare, isValidKey);
    }
    SplayTreeSet<E> result = SplayTreeSet<E>(compare, isValidKey);
    for (var element in elements) {
      result.add(element as dynamic);
    }
    return result;
  }

  /// Creates a [SplayTreeSet] from [elements].
  ///
  /// The set works as if created by `new SplayTreeSet<E>(compare, isValidKey)`.
  ///
  /// All the [elements] should be valid as arguments to the [compare] function.
  factory SplayTreeSet.of(Iterable<E> elements,
          [int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey]) =>
      SplayTreeSet(compare, isValidKey)..addAll(elements);

  Set<T> _newSet<T>() => SplayTreeSet<T>((T a, T b) => _compare(a as E, b as E), _validKey);

  Set<R> cast<R>() => Set.castFrom<E, R>(this, newSet: _newSet);

  // From Iterable.

  Iterator<E> get iterator => _SplayTreeKeyIterator<E, _SplayTreeSetNode<E>>(this);

  int get length => _count;
  bool get isEmpty => _root == null;
  bool get isNotEmpty => _root != null;

  E get first {
    if (_count == 0) throw IterableElementError.noElement();
    return _first.key;
  }

  E get last {
    if (_count == 0) throw IterableElementError.noElement();
    return _last.key;
  }

  E get single {
    if (_count == 0) throw IterableElementError.noElement();
    if (_count > 1) throw IterableElementError.tooMany();
    return _root.key;
  }

  // From Set.
  bool contains(Object element) {
    return _validKey(element) && _splay(element as E) == 0;
  }

  bool add(E element) {
    int compare = _splay(element);
    if (compare == 0) return false;
    _addNewRoot(_SplayTreeSetNode(element), compare);
    return true;
  }

  bool remove(Object object) {
    if (!_validKey(object)) return false;
    return _remove(object as E) != null;
  }

  void addAll(Iterable<E> elements) {
    for (E element in elements) {
      int compare = _splay(element);
      if (compare != 0) {
        _addNewRoot(_SplayTreeSetNode(element), compare);
      }
    }
  }

  void removeAll(Iterable<Object> elements) {
    for (Object element in elements) {
      if (_validKey(element)) _remove(element as E);
    }
  }

  void retainAll(Iterable<Object> elements) {
    // Build a set with the same sense of equality as this set.
    SplayTreeSet<E> retainSet = SplayTreeSet<E>(_compare, _validKey);
    int modificationCount = _modificationCount;
    for (Object object in elements) {
      if (modificationCount != _modificationCount) {
        // The iterator should not have side effects.
        throw ConcurrentModificationError(this);
      }
      // Equivalent to this.contains(object).
      if (_validKey(object) && _splay(object as E) == 0) {
        retainSet.add(_root.key);
      }
    }
    // Take over the elements from the retained set, if it differs.
    if (retainSet._count != _count) {
      _root = retainSet._root;
      _count = retainSet._count;
      _modificationCount++;
    }
  }

  E lookup(Object object) {
    if (!_validKey(object)) return null;
    int comp = _splay(object as E);
    if (comp != 0) return null;
    return _root.key;
  }

  Set<E> intersection(Set<Object> other) {
    Set<E> result = SplayTreeSet<E>(_compare, _validKey);
    for (E element in this) {
      if (other.contains(element)) result.add(element);
    }
    return result;
  }

  Set<E> difference(Set<Object> other) {
    Set<E> result = SplayTreeSet<E>(_compare, _validKey);
    for (E element in this) {
      if (!other.contains(element)) result.add(element);
    }
    return result;
  }

  Set<E> union(Set<E> other) {
    return _clone()..addAll(other);
  }

  SplayTreeSet<E> _clone() {
    var set = SplayTreeSet<E>(_compare, _validKey);
    set._count = _count;
    set._root = _copyNode<_SplayTreeSetNode<E>>(_root);
    return set;
  }

  // Copies the structure of a SplayTree into a new similar structure.
  // Works on _SplayTreeMapNode as well, but only copies the keys,
  _SplayTreeSetNode<E> _copyNode<Node extends _SplayTreeNode<E, Node>>(Node node) {
    if (node == null) return null;
    // Given a source node and a destination node, copy the left
    // and right subtrees of the source node into the destination node.
    // The left subtree is copied recursively, but the right spine
    // of every subtree is copied iteratively.
    void copyChildren(Node node, _SplayTreeSetNode<E> dest) {
      Node left;
      Node right;
      do {
        left = node.left;
        right = node.right;
        if (left != null) {
          var newLeft = _SplayTreeSetNode<E>(left.key);
          dest.left = newLeft;
          // Recursively copy the left tree.
          copyChildren(left, newLeft);
        }
        if (right != null) {
          var newRight = _SplayTreeSetNode<E>(right.key);
          dest.right = newRight;
          // Set node and dest to copy the right tree iteratively.
          node = right;
          dest = newRight;
        }
      } while (right != null);
    }

    var result = _SplayTreeSetNode<E>(node.key);
    copyChildren(node, result);
    return result;
  }

  void clear() {
    _clear();
  }

  Set<E> toSet() => _clone();

  String toString() => IterableBase.iterableToFullString(this, '{', '}');
}

abstract class _SplayTreeIterator<K, Node extends _SplayTreeNode<K, Node>, T> implements Iterator<T> {
  final _SplayTree<K, Node> _tree;

  /// Worklist of nodes to visit.
  ///
  /// These nodes have been passed over on the way down in a
  /// depth-first left-to-right traversal. Visiting each node,
  /// and their right subtrees will visit the remainder of
  /// the nodes of a full traversal.
  ///
  /// Only valid as long as the original tree isn't reordered.
  final List<Node> _workList = [];

  /// Original modification counter of [_tree].
  ///
  /// Incremented on [_tree] when a key is added or removed.
  /// If it changes, iteration is aborted.
  ///
  /// Not final because some iterators may modify the tree knowingly,
  /// and they update the modification count in that case.
  int _modificationCount;

  /// Count of splay operations on [_tree] when [_workList] was built.
  ///
  /// If the splay count on [_tree] increases, [_workList] becomes invalid.
  int _splayCount;

  /// Current node.
  Node _currentNode;

  _SplayTreeIterator(_SplayTree<K, Node> tree)
      : _tree = tree,
        _modificationCount = tree._modificationCount,
        _splayCount = tree._splayCount {
    _findLeftMostDescendent(tree._root);
  }

  _SplayTreeIterator.startAt(_SplayTree<K, Node> tree, K startKey)
      : _tree = tree,
        _modificationCount = tree._modificationCount,
        _splayCount = -1 {
    if (tree._root == null) return;
    int compare = tree._splay(startKey);
    _splayCount = tree._splayCount;
    if (compare < 0) {
      // Don't include the root, start at the next element after the root.
      _findLeftMostDescendent(tree._root.right);
    } else {
      _workList.add(tree._root);
    }
  }

  T get current {
    var node = _currentNode;
    if (node == null) return null as T;
    return _getValue(node);
  }

  void _findLeftMostDescendent(Node node) {
    while (node != null) {
      _workList.add(node);
      node = node.left;
    }
  }

  /// Called when the tree structure of the tree has changed.
  ///
  /// This can be caused by a splay operation.
  /// If the key-set changes, iteration is aborted before getting
  /// here, so we know that the keys are the same as before, it's
  /// only the tree that has been reordered.
  void _rebuildWorkList(Node currentNode) {
    assert(_workList.isNotEmpty);
    _workList.clear();
    _tree._splay(currentNode.key);
    _findLeftMostDescendent(_tree._root.right);
    assert(_workList.isNotEmpty);
  }

  bool moveNext() {
    if (_modificationCount != _tree._modificationCount) {
      throw ConcurrentModificationError(_tree);
    }
    // Picks the next element in the worklist as current.
    // Updates the worklist with the left-most path of the current node's
    // right-hand child.
    // If the worklist is no longer valid (after a splay), it is rebuild
    // from scratch.
    if (_workList.isEmpty) {
      _currentNode = null;
      return false;
    }
    if (_tree._splayCount != _splayCount && _currentNode != null) {
      _rebuildWorkList(_currentNode);
    }
    _currentNode = _workList.removeLast();
    _findLeftMostDescendent(_currentNode.right);
    return true;
  }

  T _getValue(Node node);
}

class _SplayTreeKeyIterator<K, Node extends _SplayTreeNode<K, Node>> extends _SplayTreeIterator<K, Node, K> {
  _SplayTreeKeyIterator(_SplayTree<K, Node> map) : super(map);
  K _getValue(Node node) => node.key;
}

class _SplayTreeNodeIterator<K, Node extends _SplayTreeNode<K, Node>> extends _SplayTreeIterator<K, Node, Node> {
  _SplayTreeNodeIterator(_SplayTree<K, Node> tree) : super(tree);
  _SplayTreeNodeIterator.startAt(_SplayTree<K, Node> tree, K startKey) : super.startAt(tree, startKey);
  Node _getValue(Node node) => node;
}

/// A collection used to identify cyclic lists during toString() calls.
final List<Object> _toStringVisiting = [];

/// Check if we are currently visiting `o` in a toString call.
bool _isToStringVisiting(Object o) {
  for (int i = 0; i < _toStringVisiting.length; i++) {
    if (identical(o, _toStringVisiting[i])) return true;
  }
  return false;
}

abstract class _MapBase<K, V> extends MapMixin<K, V> {
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
  static void _fillMapWithMappedIterable(Map<Object, Object> map, Iterable<Object> iterable,
      Object Function(Object element) key, Object Function(Object element) value) {
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
  static void _fillMapWithIterables(Map<Object, Object> map, Iterable<Object> keys, Iterable<Object> values) {
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

abstract class IterableElementError {
  /** Error thrown thrown by, e.g., [Iterable.first] when there is no result. */
  static StateError noElement() => new StateError("No element");
  /** Error thrown by, e.g., [Iterable.single] if there are too many results. */
  static StateError tooMany() => new StateError("Too many elements");
  /** Error thrown by, e.g., [List.setRange] if there are too few elements. */
  static StateError tooFew() => new StateError("Too few elements");
}

class IndexKey {
  int preHideNumber = 0;
  int originStartIndex;
  int originEndIndex;

  int _newIndex;
  IndexKey({int newIndex, this.originStartIndex, this.originEndIndex}) : _newIndex = newIndex;

  bool merge(int oringIndex) {
    if (oringIndex + 1 == originStartIndex) {
      originStartIndex--;
      return true;
    } else if (oringIndex - 1 == originStartIndex) {
      originEndIndex++;
      return true;
    }
    return false;
  }

  bool mergeRange(int startIndex, int endIndex) {
    if (endIndex + 1 == originStartIndex) {
      originStartIndex -= (endIndex - startIndex + 1);
      return true;
    } else if (startIndex - 1 == originStartIndex) {
      originEndIndex += (endIndex - startIndex + 1);
      return true;
    }
    return false;
  }
}

class IndexNode<K> extends _SplayTreeSetNode<K> {
  IndexNode(K key) : super(key);
}

class IndexHideManager {
  SplayTreeSet<IndexKey> _treeSet = SplayTreeSet<IndexKey>((a, b) {
    if (a._newIndex != null && b._newIndex == null) {
      if (a._newIndex < b.originStartIndex - b.preHideNumber) return -1;
      if (a._newIndex > b.originEndIndex - b.preHideNumber) return 1;
      return 0;
    } else if (a._newIndex == null && b._newIndex != null) {
      if (b._newIndex < a.originStartIndex - a.preHideNumber) return 1;
      if (b._newIndex > a.originEndIndex - a.preHideNumber) return -1;
      return 0;
    }
    return a.originStartIndex.compareTo(b.originStartIndex);
  });

  void hide(int oringIndex) {
    assert(oringIndex != null);
    IndexKey searchKey = IndexKey(originStartIndex: oringIndex);
    int comp = _treeSet._splay(searchKey);
    if (comp != 0) {
      if (_treeSet._root?.key?.merge(oringIndex) != true) {
        if (comp < 0) {
          IndexKey rightMinKey = _treeSet._splayMin(_treeSet._root.right)?.key;
          if (rightMinKey?.merge(oringIndex) != true) {
            _treeSet.add(searchKey);
          }
        } else {
          IndexKey leftMaxKey = _treeSet._splayMax(_treeSet._root.left)?.key;
          if (leftMaxKey?.merge(oringIndex) != true) {
            _treeSet.add(searchKey);
          }
        }
      }
    }
    Iterator iterator = _SplayTreeNodeIterator.startAt(_treeSet, _treeSet._root.right);
    while (iterator.moveNext()) {
      IndexKey key = iterator.current;
      key.preHideNumber++;
    }
  }

  void show(int oringIndex) {
    assert(oringIndex != null);
    int comp = _treeSet._splay(IndexKey(originStartIndex: oringIndex));
    IndexKey rootKey = _treeSet._root?.key;
    if (comp == 0) {
      if (oringIndex == rootKey.originStartIndex) {
        rootKey.originStartIndex++;
      } else if (oringIndex == rootKey.originEndIndex) {
        rootKey.originEndIndex--;
      }
    }
    Iterator iterator = _SplayTreeNodeIterator.startAt(_treeSet, _treeSet._root.right);
    while (iterator.moveNext()) {
      IndexKey key = iterator.current;
      key.preHideNumber--;
    }
  }

  void hideRange(int oringStartIndex, int originEndIndex) {
    assert(oringStartIndex != null && originEndIndex != null);
    IndexKey searchKey = IndexKey(originStartIndex: oringStartIndex, originEndIndex: originEndIndex);
    int comp = _treeSet._splay(searchKey);
    if (comp != 0) {
      if (_treeSet._root?.key?.mergeRange(oringStartIndex, originEndIndex) != true) {
        if (comp < 0) {
          IndexKey rightMinKey = _treeSet._splayMin(_treeSet._root.right)?.key;
          if (rightMinKey?.mergeRange(oringStartIndex, originEndIndex) != true) {
            _treeSet.add(searchKey);
          }
        } else {
          IndexKey leftMaxKey = _treeSet._splayMax(_treeSet._root.left)?.key;
          if (leftMaxKey?.mergeRange(oringStartIndex, originEndIndex) != true) {
            _treeSet.add(searchKey);
          }
        }
      }
    }
  }

  void showRange(int oringStartIndex, int originEndIndex) {
    assert(oringStartIndex != null && originEndIndex != null);
  }

  int indexOf(int newIndex) {
    assert(newIndex != null);
    int comp = _treeSet._splay(IndexKey(newIndex: newIndex));
    if (comp != 0) return newIndex;
    return newIndex + _treeSet._root.key.preHideNumber;
  }

  // int get hideNumber => _treeSet._last;

  void clear() {
    _treeSet.clear();
  }
}
