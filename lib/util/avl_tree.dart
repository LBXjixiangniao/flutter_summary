import 'dart:collection';
import 'binary_tree.dart';
import 'maps.dart';

typedef _Predicate<T> = bool Function(T value);
typedef _ReplaceCheck<T> = bool Function(T oldValue, T newValue);

/// AVL树节点
/**
 * 二叉树节点的平衡因子A的被定义为高度差（右子树高度-左子树高度）
 * 如果二叉搜索树所有节点的平衡因子在{-1,0,1}范围内，则称为AVL树
 * 如果节点平衡因子 < 0，被称为“左重”；如果节点平衡因子 > 0，被称为“右重”；如果节点平衡因子 == 0， 有时简称为“平衡”
 */
class _AVLTreeNode<K, Node extends _AVLTreeNode<K, Node>> extends BinaryTreeNode<K, Node> {
  ///平衡因子，新节点没有子树，所以平衡因子为0
  int factor = 0;
  _AVLTreeNode(K key) : super(key);

  @override
  int get height {
    if (this == null) return 0;
    if (factor > 0) {
      return 1 + (right?.height ?? 0);
    } else {
      return 1 + (left?.height ?? 0);
    }
  }

  @override
  // String get debugString => '$key($factor)';
  String get debugString {
    if (factor > 0) {
      return '$key+';
    } else if (factor < 0) {
      return '$key-';
    } else {
      return key.toString();
    }
  }
}

/// 基于AVL树实现的Set的节点
class _AVLTreeSetNode<K> extends _AVLTreeNode<K, _AVLTreeSetNode<K>> {
  _AVLTreeSetNode(K key) : super(key);
}

/// 基于AVL树实现的Map的节点
/// 一个包含value值的_AVLTreeNode
class _AVLTreeMapNode<K, V> extends _AVLTreeNode<K, _AVLTreeMapNode<K, V>> {
  V value;
  _AVLTreeMapNode(K key, this.value) : super(key);
}

/// AVL树实现
abstract class _AVLTree<K, Node extends _AVLTreeNode<K, Node>> {
  // AVL树根节点
  Node get _root;
  set _root(Node newValue);

  /// AVL书中元素个数
  int _count = 0;

  /// 每次增删都会加1，用来识别并发修改
  int _modificationCount = 0;

  /// 用于比较
  Comparator<K> get _compare;

  /// 判断是否key有效
  _Predicate get _validKey;

  ///是否调试模式
  ///调试模式下增、删后会打印出整个AVL树，且搜索的时候会打印出查找路径
  bool debug = false;

  ///插入
  ///node：新插入的节点
  ///root：指定查找的根结点，如果root不为null，则node会插入在root的子树上
  ///replaceIfExist：如果存在与node的key相等的节点，则通过replaceIfExist判断是否用node代替已有节点，
  ///如果replaceIfExist不为null且返回true则代替，否则不代替
  void _insert(Node node, {Node root, _ReplaceCheck<Node> replaceIfExist}) {
    if(node == null) return;
    String searchPath = '';
    assert(() {
      if (debug) print('Insert:${node.key}**********************************\n');
      return true;
    }());

    if (_root == null) {
      _root = node;
      _count++;
    } else {
      var compare = _compare;
      int comp;

      void add(Node parent) {
        assert(() {
          if (debug) searchPath += '->${parent.key}';
          return true;
        }());
        comp = compare(node.key, parent.key);
        if (comp == 0) {
          if (replaceIfExist?.call(parent, node) == true) {
            ///用node替换parent
            _replaceNode(parent, node);
          }
        } else if (comp < 0) {
          if (parent.left != null) {
            add(parent.left);
          } else {
            parent.left = node;
            node.parent = parent;
            _count++;
          }
        } else {
          if (parent.right != null) {
            add(parent.right);
          } else {
            parent.right = node;
            node.parent = parent;
            _count++;
          }
        }
      }

      add(root ?? _root);
      _rebalanceForInsert(node);
    }
    _modificationCount++;
    assert(() {
      if (debug) print(searchPath);
      return true;
    }());
    assert(() {
      if (debug) _printTree();
      return true;
    }());
  }

  ///Z刚通过_insert方法插入的节点
  void _rebalanceForInsert(Node Z) {
    assert(() {
      if (debug) print('RebalanceForInsert:${Z.key.toString()}');
      return true;
    }());
    Node G;
    Node N;
    for (Node X = Z.parent; X != null; X = Z.parent) {
      // Loop (possibly up to the root)
      // BalanceFactor(X) has to be updated:
      if (Z == X.right) {
        // The right subtree increases
        if (X.factor > 0) {
          // X is right-heavy
          // ===> the temporary BalanceFactor(X) == +2
          // ===> rebalancing is required.
          G = X.parent; // Save parent of X around rotations
          if (Z.factor < 0) // Right Left Case     (see figure 5)
            N = _rotateRightLeft(X, Z); // Double rotation: Right(Z) then Left(X)
          else // Right Right Case    (see figure 4)
            N = _rotateLeft(X, Z); // Single rotation Left(X)
          // After rotation adapt parent link
        } else {
          if (X.factor < 0) {
            X.factor = 0; // Z’s height increase is absorbed at X.
            break; // Leave the loop
          }
          X.factor = 1;
          Z = X; // Height(Z) increases by 1
          continue;
        }
      } else {
        // Z == left_child(X): the left subtree increases
        if (X.factor < 0) {
          // X is left-heavy
          // ===> the temporary BalanceFactor(X) == –2
          // ===> rebalancing is required.
          G = X.parent; // Save parent of X around rotations
          if (Z.factor > 0) // Left Right Case
            N = _rotateLeftRight(X, Z); // Double rotation: Left(Z) then Right(X)
          else // Left Left Case
            N = _rotateRight(X, Z); // Single rotation Right(X)
          // After rotation adapt parent link
        } else {
          if (X.factor > 0) {
            X.factor = 0; // Z’s height increase is absorbed at X.
            break; // Leave the loop
          }
          X.factor = -1;
          Z = X; // Height(Z) increases by 1
          continue;
        }
      }
      // After a rotation adapt parent link:
      // N is the new root of the rotated subtree
      // Height does not change: Height(N) == old Height(X)
      N.parent = G;
      if (G != null) {
        if (X == G.left)
          G.left = N;
        else
          G.right = N;
      } else
        _root = N; // N is the new root of the total tree
      break;
      // There is no fall thru, only break; or continue;
    }
// Unless loop is left via break, the height of the total tree increases by 1.
  }

  ///删除
  ///key: 需要删除的节点的key值
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找key删除node
  Node _delete(K key, {Node root}) {
    String searchPath = '';
    assert(() {
      if (debug) print('Delete:$key**********************************\n');
      return true;
    }());

    ///用newNode代替oldNode在oldNode.parent中的位置,_delete方法中只有此处才可能导致子树高度减一
    ///所以在此方法中判断是否需要重新平衡即可
    void replaceNodeInParent(Node oldNode, Node newNode) {
      if (oldNode == null) return;
      if (oldNode == _root) {
        _root = newNode;
        return;
      }

      ///进行平衡
      if (newNode != null) {
        newNode.parent = oldNode.parent;
        if (newNode.parent.factor != 0) {
          _rebalanceForDelete(newNode);
        } else if (oldNode.parent?.left == oldNode) {
          oldNode.parent.factor = 1;
        } else if (oldNode.parent?.right == oldNode) {
          oldNode.parent.factor = -1;
        }
      } else {
        ///先不删除oldNode，将其认为是树高度减1用于做平衡先，
        ///平衡完了再删除oldNode
        _rebalanceForDelete(oldNode);
      }

      ///删除oldNode
      if (oldNode.parent?.left == oldNode) {
        oldNode.parent.left = newNode;
      } else if (oldNode.parent?.right == oldNode) {
        oldNode.parent.right = newNode;
      }
      _count--;
      _modificationCount++;
    }

    if (_root == null || key == null)
      return null;
    else {
      var compare = _compare;
      int comp;

      Node remove(Node parent) {
        if (parent == null) return null;
        assert(() {
          if (debug) searchPath += '->${parent.key}';
          return true;
        }());
        comp = compare(key, parent.key);
        if (comp == 0) {
          if (parent.left != null && parent.right != null) {
            Node min = _findMin(root: parent.right);
            _delete(min.key, root: parent.right);
            _replaceNode(parent, min);
          } else if (parent.left != null) {
            replaceNodeInParent(parent, parent.left);
          } else if (parent.right != null) {
            replaceNodeInParent(parent, parent.right);
          } else {
            replaceNodeInParent(parent, null);
          }
          return parent;
        } else if (comp < 0) {
          return remove(parent.left);
        } else {
          return remove(parent.right);
        }
      }

      Node deletedNode = remove(root ?? _root);
      if (deletedNode != null) {
        deletedNode.left = null;
        deletedNode.right = null;
        deletedNode.parent = null;
      }
      assert(() {
        if (debug) print(searchPath);
        return true;
      }());
      assert(() {
        if (debug) _printTree();
        return true;
      }());
      return deletedNode;
    }
  }

  ///node为跟的子树高度降低了1，且N是已经已经平衡的AVL子树
  void _rebalanceForDelete(Node N) {
    assert(() {
      if (debug) print('RebalanceForDelete:${N.key.toString()}');
      return true;
    }());
    Node G;
    Node Z;
    int b;
    for (Node X = N.parent; X != null; X = G) {
      // Loop (possibly up to the root)
      G = X.parent; // Save parent of X around rotations
      // BalanceFactor(X) has not yet been updated!
      if (N == X.left) {
        // the left subtree decreases
        if (X.factor > 0) {
          // X is right-heavy
          // ===> the temporary BalanceFactor(X) == +2
          // ===> rebalancing is required.
          Z = X.right; // Sibling of N (higher by 2)
          b = Z.factor;
          if (b < 0) // Right Left Case     (see figure 5)
            N = _rotateRightLeft(X, Z); // Double rotation: Right(Z) then Left(X)
          else // Right Right Case    (see figure 4)
            N = _rotateLeft(X, Z); // Single rotation Left(X)
          // After rotation adapt parent link
        } else {
          if (X.factor == 0) {
            X.factor = 1; // N’s height decrease is absorbed at X.
            break; // Leave the loop
          }
          N = X;
          N.factor = 0; // Height(N) decreases by 1
          continue;
        }
      } else {
        // (N == right_child(X)): The right subtree decreases
        if (X.factor < 0) {
          // X is left-heavy
          // ===> the temporary BalanceFactor(X) == –2
          // ===> rebalancing is required.
          Z = X.left; // Sibling of N (higher by 2)
          b = Z.factor;
          if (b > 0) // Left Right Case
            N = _rotateLeftRight(X, Z); // Double rotation: Left(Z) then Right(X)
          else // Left Left Case
            N = _rotateRight(X, Z); // Single rotation Right(X)
          // After rotation adapt parent link
        } else {
          if (X.factor == 0) {
            X.factor = -1; // N’s height decrease is absorbed at X.
            break; // Leave the loop
          }
          N = X;
          N.factor = 0; // Height(N) decreases by 1
          continue;
        }
      }
      // After a rotation adapt parent link:
      // N is the new root of the rotated subtree
      N.parent = G;
      if (G != null) {
        if (X == G.left)
          G.left = N;
        else
          G.right = N;
      } else
        _root = N; // N is the new root of the total tree

      if (b == 0) break; // Height does not change: Leave the loop

      // Height(N) decreases by 1 (== old Height(X)-1)
    }
// If (b != 0) the height of the total tree decreases by 1.
  }

  ///用newNode代替oldNode，newNode的parent、left、right都是从oldNode来
  void _replaceNode(Node oldNode, Node newNode) {
    assert(() {
      if (debug) print('Replace ${oldNode.key.toString()} with ${newNode.key.toString()}\n');
      return true;
    }());
    if (oldNode == null) return;
    if (newNode != null) {
      newNode.left = oldNode.left;
      newNode.left?.parent = newNode;
      newNode.right = oldNode.right;
      newNode.right?.parent = newNode;
      newNode.parent = oldNode.parent;

      newNode.factor = oldNode.factor;
    }

    if (oldNode.parent?.left == oldNode) {
      oldNode.parent.left = newNode;
    } else if (oldNode.parent?.right == oldNode) {
      oldNode.parent.right = newNode;
    }

    if (oldNode == _root) {
      _root = newNode;
    }

    oldNode.left = null;
    oldNode.right = null;
    oldNode.parent = null;
  }

  ///查找node.key == key的node
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找
  Node _search(K key, {Node root}) {
    String searchPath = '';
    assert(() {
      if (debug) print('Search:**********************************\n');
      return true;
    }());
    if (_root == null || key == null)
      return null;
    else {
      var compare = _compare;
      int comp;
      int initialModificationCount = _modificationCount;
      Node searchRecursively(Node parent) {
        if (parent == null) return null;
        assert(() {
          if (debug) searchPath += '->${parent.key}';
          return true;
        }());
        if (initialModificationCount != _modificationCount) {
          throw ConcurrentModificationError(this);
        }
        comp = compare(key, parent.key);
        if (comp == 0) {
          return parent;
        } else if (comp < 0) {
          return searchRecursively(parent.left);
        } else {
          return searchRecursively(parent.right);
        }
      }

      Node resultNode = searchRecursively(root ?? _root);
      assert(() {
        if (debug) print(searchPath);
        return true;
      }());
      return resultNode;
    }
  }

  ///单次左旋，对应于右右情况
  /**
   *    X
   *   /  \
   * t1     Z
   *       /  \
   *      t23  t4
   * 
   *        Z
   *      /   \
   *     X     t4
   *   /  \   
   * t1   t23
   *       
   */
  Node _rotateLeft(Node X, Node Z) {
    assert(() {
      if (debug) print('RotateLeft:${X.key.toString()},${Z.key.toString()}\n');
      return true;
    }());
    // Z is by 2 higher than its sibling
    Node t23 = Z.left; // Inner child of Z
    X.right = t23;
    if (t23 != null) t23.parent = X;
    Z.left = X;
    X.parent = Z;
    // 1st case, BalanceFactor(Z) == 0, only happens with deletion, not insertion:
    if (Z.factor == 0) {
      // t23 has been of same height as t4
      X.factor = 1; // t23 now higher
      Z.factor = -1; // t4 now lower than X
    } else {
      // 2nd case happens with insertion or deletion:
      X.factor = 0;
      Z.factor = 0;
    }
    return Z; // return new root of rotated subtree
  }

  ///单次右旋，对应于左左情况
  /**
   *        X
   *      /   \
   *     Z     t4
   *   /  \   
   * t1   t23
   * 
   *    Z
   *   /  \
   * t1     X
   *       /  \
   *      t23  t4
   *       
   */
  Node _rotateRight(Node X, Node Z) {
    assert(() {
      if (debug) print('RotateRight:${X.key.toString()},${Z.key.toString()}\n');
      return true;
    }());
    // Z is by 2 higher than its sibling
    Node t23 = Z.right; // Inner child of Z
    X.left = t23;
    if (t23 != null) t23.parent = X;
    Z.right = X;
    X.parent = Z;
    // 1st case, BalanceFactor(Z) == 0, only happens with deletion, not insertion:
    if (Z.factor == 0) {
      // t23 has been of same height as t4
      X.factor = -1; // t23 now higher
      Z.factor = 1; // t4 now lower than X
    } else {
      // 2nd case happens with insertion or deletion:
      X.factor = 0;
      Z.factor = 0;
    }
    return Z; // return new root of rotated subtree
  }

  ///对应于右左情况的旋转,Z的高度比t1高2。t1、t2、t3、t4中，（1）t2或者t3比其他三个高度小1，（2）所有等高。
  /**
   *    X
   *   /  \
   * t1     Z
   *       /  \
   *      Y    t4
   *     /  \
   *    t2   t3
   * 
   *     X
   *   /  \
   * t1     Y
   *       /  \
   *      t2   Z
   *          /  \
   *         t3   t4
   * 
   *        Y
   *      /   \
   *     X     Z
   *   /  \   /  \
   * t1   t2 t3   t4
   *       
   */
  Node _rotateRightLeft(Node X, Node Z) {
    assert(() {
      if (debug) print('RotateRightLeft:${X.key.toString()},${Z.key.toString()}\n');
      return true;
    }());
    // Z is by 2 higher than its sibling
    Node Y = Z.left; // Inner child of Z
    // Y is by 1 higher than sibling
    Node t3 = Y.right;
    Z.left = t3;
    if (t3 != null) t3.parent = Z;
    Y.right = Z;
    Z.parent = Y;

    Node t2 = Y.left;
    X.right = t2;
    if (t2 != null) t2.parent = X;
    Y.left = X;
    X.parent = Y;

    ///修正平衡因子
    if (Y.factor > 0) {
      // t3 was higher
      X.factor = -1; // t1 now higher
      Z.factor = 0;
    } else if (Y.factor == 0) {
      //t2、t3等高
      X.factor = 0;
      Z.factor = 0;
    } else {
      // t2 was higher
      X.factor = 0;
      Z.factor = 1; // t4 now higher
    }
    Y.factor = 0;
    return Y; // return new root of rotated subtree
  }

  ///对应于左右情况的旋转，Z的高度比t4高2。t1、t2、t3、t4中，（1）t2或者t3比其他三个高度小1，（2）所有等高。
  /**
   *        X
   *      /   \
   *     Z     t4
   *   /  \   
   * t1    Y
   *      /  \
   *     t2   t3
   * 
   *       X
   *      /  \
   *     Y    t4
   *    /  \
   *   Z    t3
   *  /  \
   * t1   t2
   * 
   *        Y
   *      /   \
   *     Z     X
   *   /  \   /  \
   * t1   t2 t3   t4
   *       
   */
  Node _rotateLeftRight(Node X, Node Z) {
    assert(() {
      if (debug) print('RotateLeftRight:${X.key.toString()},${Z.key.toString()}\n');
      return true;
    }());
    // Z is by 2 higher than its sibling
    Node Y = Z.right; // Inner child of Z
    // Y is by 1 higher than sibling
    Node t2 = Y.left;
    Z.right = t2;
    if (t2 != null) t2.parent = Z;
    Y.left = Z;
    Z.parent = Y;

    Node t3 = Y.right;
    X.left = t3;
    if (t3 != null) t3.parent = X;
    Y.right = X;
    X.parent = Y;

    ///修正平衡因子
    if (Y.factor > 0) {
      // t3 was higher
      Z.factor = -1; // t1 now higher
      X.factor = 0;
    } else if (Y.factor == 0) {
      //t2、t3等高
      X.factor = 0;
      Z.factor = 0;
    } else {
      // t2 was higher
      Z.factor = 0;
      X.factor = 1; // t4 now higher
    }
    Y.factor = 0;
    return Y; // return new root of rotated subtree
  }

  ///查找最小值
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找
  Node _findMin({Node root}) {
    Node minNode = root ?? _root;
    if (minNode == null) return minNode;
    while (minNode.left != null) {
      minNode = minNode.left;
    }
    return minNode;
  }

  ///查找最大值
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找
  Node _findMax({Node root}) {
    Node minNode = root ?? _root;
    if (minNode == null) return minNode;
    while (minNode.right != null) {
      minNode = minNode.right;
    }
    return minNode;
  }

  Node get _first {
    return _findMin();
  }

  Node get _last {
    return _findMax();
  }

  /// Get the last node in the tree that is strictly smaller than [key]. Returns
  /// `null` if no key was not found.
  Node _lastBefore(K key) {
    if (key == null) throw ArgumentError(key);
    if (_root == null) return null;
    var compare = _compare;
    int comp;
    int initialModificationCount = _modificationCount;
    Node resultNode;
    void searchRecursively(Node parent) {
      if (parent == null) return;
      if (initialModificationCount != _modificationCount) {
        throw ConcurrentModificationError(this);
      }
      comp = compare(key, parent.key);
      if (comp == 0) {
        return;
      } else if (comp < 0) {
        return searchRecursively(parent.left);
      } else {
        resultNode = parent;
        return searchRecursively(parent.right);
      }
    }

    searchRecursively(_root);
    return resultNode;
  }

  /// Get the first node in the tree that is strictly larger than [key]. Returns
  /// `null` if no key was not found.
  Node _firstAfter(K key) {
    if (key == null) throw ArgumentError(key);
    if (_root == null) return null;
    var compare = _compare;
    int comp;
    int initialModificationCount = _modificationCount;
    Node resultNode;
    void searchRecursively(Node parent) {
      if (parent == null) return;
      if (initialModificationCount != _modificationCount) {
        throw ConcurrentModificationError(this);
      }
      comp = compare(key, parent.key);
      if (comp == 0) {
        return;
      } else if (comp < 0) {
        resultNode = parent;
        return searchRecursively(parent.left);
      } else {
        return searchRecursively(parent.right);
      }
    }

    searchRecursively(_root);
    return resultNode;
  }

  void _clear() {
    _root = null;
    _count = 0;
    _modificationCount++;
  }

  String treeStructureString() {
    return BinaryTreePrinter.treeStructureString(_root);
  }

  void debugPrint() {
    assert(() {
      _printTree();
      return true;
    }());
  }

  ///打印整个树结构
  void _printTree() {
    BinaryTreePrinter.printTree(_root);
  }
}

int _dynamicCompare(dynamic a, dynamic b) => Comparable.compare(a, b);

Comparator<K> _defaultCompare<K>() {
  Object compare = Comparable.compare;
  if (compare is Comparator<K>) {
    return compare;
  }
  return _dynamicCompare;
}

/// A [Map] of objects that can be ordered relative to each other.
///
/// The map is based on a AVL tree. It allows most operations
/// in amortized logarithmic time.
///
/// Keys of the map are compared using the `compare` function passed in
/// the constructor, both for ordering and for equality.
/// If the map contains only the key `a`, then `map.containsKey(b)`
/// will return `true` if and only if `compare(a, b) == 0`,
/// and the value of `a == b` is not even checked.
/// If the compare function is omitted, the objects are assumed to be
/// [Comparable], and are compared using their [Comparable.compareTo] method.
/// Non-comparable objects (including `null`) will not work as keys
/// in that case.
///
/// To allow calling [operator []], [remove] or [containsKey] with objects
/// that are not supported by the `compare` function, an extra `isValidKey`
/// predicate function can be supplied. This function is tested before
/// using the `compare` function on an argument value that may not be a [K]
/// value. If omitted, the `isValidKey` function defaults to testing if the
/// value is a [K].
class AVLTreeMap<K, V> extends _AVLTree<K, _AVLTreeMapNode<K, V>> with MapMixin<K, V> {
  _AVLTreeMapNode<K, V> _root;

  Comparator<K> _compare;
  _Predicate _validKey;

  AVLTreeMap([int Function(K key1, K key2) compare, bool Function(dynamic potentialKey) isValidKey])
      : _compare = compare ?? _defaultCompare<K>(),
        _validKey = isValidKey ?? ((dynamic v) => v is K);

  /// Creates a [AVLTreeMap] that contains all key/value pairs of [other].
  ///
  /// The keys must all be instances of [K] and the values of [V].
  /// The [other] map itself can have any type.
  factory AVLTreeMap.from(Map<dynamic, dynamic> other,
      [int Function(K key1, K key2) compare, bool Function(dynamic potentialKey) isValidKey]) {
    if (other is Map<K, V>) {
      return AVLTreeMap<K, V>.of(other, compare, isValidKey);
    }
    AVLTreeMap<K, V> result = AVLTreeMap<K, V>(compare, isValidKey);
    other.forEach((dynamic k, dynamic v) {
      result[k] = v;
    });
    return result;
  }

  /// Creates a [AVLTreeMap] that contains all key/value pairs of [other].
  factory AVLTreeMap.of(Map<K, V> other,
          [int Function(K key1, K key2) compare, bool Function(dynamic potentialKey) isValidKey]) =>
      AVLTreeMap<K, V>(compare, isValidKey)..addAll(other);

  /// Creates a [AVLTreeMap] where the keys and values are computed from the
  /// [iterable].
  ///
  /// For each element of the [iterable] this constructor computes a key/value
  /// pair, by applying [key] and [value] respectively.
  ///
  /// The keys of the key/value pairs do not need to be unique. The last
  /// occurrence of a key will simply overwrite any previous value.
  ///
  /// If no functions are specified for [key] and [value] the default is to
  /// use the iterable value itself.
  factory AVLTreeMap.fromIterable(Iterable iterable,
      {K Function(dynamic element) key,
      V Function(dynamic element) value,
      int Function(K key1, K key2) compare,
      bool Function(dynamic potentialKey) isValidKey}) {
    AVLTreeMap<K, V> map = AVLTreeMap<K, V>(compare, isValidKey);
    CustomMapBase.fillMapWithMappedIterable(map, iterable, key, value);
    return map;
  }

  /// Creates a [AVLTreeMap] associating the given [keys] to [values].
  ///
  /// This constructor iterates over [keys] and [values] and maps each element
  /// of [keys] to the corresponding element of [values].
  ///
  /// If [keys] contains the same object multiple times, the last occurrence
  /// overwrites the previous value.
  ///
  /// It is an error if the two [Iterable]s don't have the same length.
  factory AVLTreeMap.fromIterables(Iterable<K> keys, Iterable<V> values,
      [int Function(K key1, K key2) compare, bool Function(dynamic potentialKey) isValidKey]) {
    AVLTreeMap<K, V> map = AVLTreeMap<K, V>(compare, isValidKey);
    CustomMapBase.fillMapWithIterables(map, keys, values);
    return map;
  }

  V operator [](Object key) {
    if (!_validKey(key)) return null;
    return _search(key)?.value;
  }

  V remove(Object key) {
    if (!_validKey(key)) return null;
    return _delete(key)?.value;
  }

  void operator []=(K key, V value) {
    if (key == null) throw ArgumentError(key);
    _AVLTreeMapNode<K, V> node = _AVLTreeMapNode<K, V>(key, value);
    _insert(node, replaceIfExist: (_, __) => true);
  }

  V putIfAbsent(K key, V ifAbsent()) {
    if (key == null) throw ArgumentError(key);
    _AVLTreeMapNode node = _AVLTreeMapNode(key, null);
    bool absent = true;
    _insert(
      node,
      replaceIfExist: (oldValue, newValue) {
        ///存在对应的key
        absent = false;
        node.value = oldValue.value;
        return false;
      },
    );
    if (absent) {
      int modificationCount = _modificationCount;
      node.value = ifAbsent();
      if (modificationCount != _modificationCount) {
        throw ConcurrentModificationError(this);
      }
    }
    return node.value;
  }

  void addAll(Map<K, V> other) {
    other.forEach((K key, V value) {
      this[key] = value;
    });
  }

  bool get isEmpty {
    return (_root == null);
  }

  bool get isNotEmpty => !isEmpty;

  void forEach(void f(K key, V value)) {
    Iterator<_AVLTreeMapNode<K, V>> nodes = _AVLTreeNodeIterator<K, _AVLTreeMapNode<K, V>>(this);
    while (nodes.moveNext()) {
      _AVLTreeMapNode<K, V> node = nodes.current;
      f(node.key, node.value);
    }
  }

  int get length {
    return _count;
  }

  void clear() {
    _clear();
  }

  bool containsKey(Object key) {
    return _validKey(key) && _search(key) != null;
  }

  bool containsValue(Object value) {
    int initialModificationCount = _modificationCount;
    bool visit(_AVLTreeMapNode<K, V> node) {
      while (node != null) {
        if (node.value == value) return true;
        if (initialModificationCount != _modificationCount) {
          throw ConcurrentModificationError(this);
        }
        if (node.right != null && visit(node.right)) {
          return true;
        }
        node = node.left;
      }
      return false;
    }

    return visit(_root);
  }

  Iterable<K> get keys => _AVLTreeKeyIterable<K, _AVLTreeMapNode<K, V>>(this);

  Iterable<V> get values => _AVLTreeValueIterable<K, V>(this);

  /// Get the first key in the map. Returns `null` if the map is empty.
  K firstKey() {
    if (_root == null) return null;
    return _first.key;
  }

  /// Get the last key in the map. Returns `null` if the map is empty.
  K lastKey() {
    if (_root == null) return null;
    return _last.key;
  }

  /// Get the last key in the map that is strictly smaller than [key]. Returns
  /// `null` if no key was not found.
  K lastKeyBefore(K key) {
    return _lastBefore(key)?.key;
  }

  /// Get the first key in the map that is strictly larger than [key]. Returns
  /// `null` if no key was not found.
  K firstKeyAfter(K key) {
    return _firstAfter(key)?.key;
  }
}

abstract class _AVLTreeIterator<K, Node extends _AVLTreeNode<K, Node>, T> implements Iterator<T> {
  final _AVLTree<K, Node> _tree;

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

  /// Current node.
  Node _currentNode;

  _AVLTreeIterator(_AVLTree<K, Node> tree)
      : _tree = tree,
        _modificationCount = tree._modificationCount {
    _findLeftMostDescendent(tree._root);
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

    _currentNode = _workList.removeLast();
    _findLeftMostDescendent(_currentNode.right);
    return true;
  }

  T _getValue(Node node);
}

class _AVLTreeKeyIterable<K, Node extends _AVLTreeNode<K, Node>> extends Iterable<K> {
  _AVLTree<K, Node> _tree;
  _AVLTreeKeyIterable(this._tree);
  int get length => _tree._count;
  bool get isEmpty => _tree._count == 0;
  Iterator<K> get iterator => _AVLTreeKeyIterator<K, Node>(_tree);

  Set<K> toSet() {
    AVLTreeSet<K> set = AVLTreeSet<K>(_tree._compare, _tree._validKey);
    set._count = _tree._count;
    set._root = set._copyNode<Node>(_tree._root);
    return set;
  }
}

class _AVLTreeValueIterable<K, V> extends Iterable<V> {
  AVLTreeMap<K, V> _map;
  _AVLTreeValueIterable(this._map);
  int get length => _map._count;
  bool get isEmpty => _map._count == 0;
  Iterator<V> get iterator => _AVLTreeValueIterator<K, V>(_map);
}

class _AVLTreeKeyIterator<K, Node extends _AVLTreeNode<K, Node>> extends _AVLTreeIterator<K, Node, K> {
  _AVLTreeKeyIterator(_AVLTree<K, Node> map) : super(map);
  K _getValue(Node node) => node.key;
}

class _AVLTreeValueIterator<K, V> extends _AVLTreeIterator<K, _AVLTreeMapNode<K, V>, V> {
  _AVLTreeValueIterator(AVLTreeMap<K, V> map) : super(map);
  V _getValue(_AVLTreeMapNode<K, V> node) => node.value;
}

class _AVLTreeNodeIterator<K, Node extends _AVLTreeNode<K, Node>> extends _AVLTreeIterator<K, Node, Node> {
  _AVLTreeNodeIterator(_AVLTree<K, Node> tree) : super(tree);
  Node _getValue(Node node) => node;
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
class AVLTreeSet<E> extends _AVLTree<E, _AVLTreeSetNode<E>> with IterableMixin<E>, SetMixin<E> {
  _AVLTreeSetNode<E> _root;

  Comparator<E> _compare;
  _Predicate _validKey;

  /// Create a new [AVLTreeSet] with the given compare function.
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
  AVLTreeSet([int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey])
      : _compare = compare ?? _defaultCompare<E>(),
        _validKey = isValidKey ?? ((dynamic v) => v is E);

  /// Creates a [AVLTreeSet] that contains all [elements].
  ///
  /// The set works as if created by `new AVLTreeSet<E>(compare, isValidKey)`.
  ///
  /// All the [elements] should be instances of [E] and valid arguments to
  /// [compare].
  /// The `elements` iterable itself may have any element type, so this
  /// constructor can be used to down-cast a `Set`, for example as:
  /// ```dart
  /// Set<SuperType> superSet = ...;
  /// Set<SubType> subSet =
  ///     new AVLTreeSet<SubType>.from(superSet.whereType<SubType>());
  /// ```
  factory AVLTreeSet.from(Iterable elements,
      [int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey]) {
    if (elements is Iterable<E>) {
      return AVLTreeSet<E>.of(elements, compare, isValidKey);
    }
    AVLTreeSet<E> result = AVLTreeSet<E>(compare, isValidKey);
    for (var element in elements) {
      result.add(element as dynamic);
    }
    return result;
  }

  /// Creates a [AVLTreeSet] from [elements].
  ///
  /// The set works as if created by `new AVLTreeSet<E>(compare, isValidKey)`.
  ///
  /// All the [elements] should be valid as arguments to the [compare] function.
  factory AVLTreeSet.of(Iterable<E> elements,
          [int Function(E key1, E key2) compare, bool Function(dynamic potentialKey) isValidKey]) =>
      AVLTreeSet(compare, isValidKey)..addAll(elements);

  Set<T> _newSet<T>() => AVLTreeSet<T>((T a, T b) => _compare(a as E, b as E), _validKey);

  Set<R> cast<R>() => Set.castFrom<E, R>(this, newSet: _newSet);

  // From Iterable.

  Iterator<E> get iterator => _AVLTreeKeyIterator<E, _AVLTreeSetNode<E>>(this);

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
    return _validKey(element) && _search(element) != null;
  }

  bool add(E element) {
    _AVLTreeSetNode<E> node = _AVLTreeSetNode<E>(element);
    bool b = true;
    _insert(node, replaceIfExist: (_, __) {
      b = false;
      return false;
    });
    return b;
  }

  bool remove(Object object) {
    if (!_validKey(object)) return false;
    return _delete(object) != null;
  }

  void addAll(Iterable<E> elements) {
    for (E element in elements) {
      _insert(_AVLTreeSetNode(element));
    }
  }

  void removeAll(Iterable<Object> elements) {
    for (Object element in elements) {
      if (_validKey(element)) _delete(element as E);
    }
  }

  void retainAll(Iterable<Object> elements) {
    // Build a set with the same sense of equality as this set.
    AVLTreeSet<E> retainSet = AVLTreeSet<E>(_compare, _validKey);
    int modificationCount = _modificationCount;
    for (Object object in elements) {
      if (modificationCount != _modificationCount) {
        // The iterator should not have side effects.
        throw ConcurrentModificationError(this);
      }
      // Equivalent to this.contains(object).
      if (_validKey(object) && _search(object) != null) {
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
    return _search(object)?.key;
  }

  Set<E> intersection(Set<Object> other) {
    Set<E> result = AVLTreeSet<E>(_compare, _validKey);
    for (E element in this) {
      if (other.contains(element)) result.add(element);
    }
    return result;
  }

  Set<E> difference(Set<Object> other) {
    Set<E> result = AVLTreeSet<E>(_compare, _validKey);
    for (E element in this) {
      if (!other.contains(element)) result.add(element);
    }
    return result;
  }

  Set<E> union(Set<E> other) {
    return _clone()..addAll(other);
  }

  AVLTreeSet<E> _clone() {
    var set = AVLTreeSet<E>(_compare, _validKey);
    set._count = _count;
    set._root = _copyNode<_AVLTreeSetNode<E>>(_root);
    return set;
  }

  // Copies the structure of a AVLTree into a new similar structure.
  // Works on _AVLTreeMapNode as well, but only copies the keys,
  _AVLTreeSetNode<E> _copyNode<Node extends _AVLTreeNode<E, Node>>(Node node) {
    if (node == null) return null;
    // Given a source node and a destination node, copy the left
    // and right subtrees of the source node into the destination node.
    // The left subtree is copied recursively, but the right spine
    // of every subtree is copied iteratively.
    void copyChildren(Node node, _AVLTreeSetNode<E> dest) {
      Node left;
      Node right;
      do {
        left = node.left;
        right = node.right;
        if (left != null) {
          var newLeft = _AVLTreeSetNode<E>(left.key);
          dest.left = newLeft;
          // Recursively copy the left tree.
          copyChildren(left, newLeft);
        }
        if (right != null) {
          var newRight = _AVLTreeSetNode<E>(right.key);
          dest.right = newRight;
          // Set node and dest to copy the right tree iteratively.
          node = right;
          dest = newRight;
        }
      } while (right != null);
    }

    var result = _AVLTreeSetNode<E>(node.key);
    copyChildren(node, result);
    return result;
  }

  void clear() {
    _clear();
  }

  Set<E> toSet() => _clone();

  String toString() => IterableBase.iterableToFullString(this, '{', '}');
}

abstract class IterableElementError {
  /** Error thrown thrown by, e.g., [Iterable.first] when there is no result. */
  static StateError noElement() => new StateError("No element");
  /** Error thrown by, e.g., [Iterable.single] if there are too many results. */
  static StateError tooMany() => new StateError("Too many elements");
  /** Error thrown by, e.g., [List.setRange] if there are too few elements. */
  static StateError tooFew() => new StateError("Too few elements");
}
