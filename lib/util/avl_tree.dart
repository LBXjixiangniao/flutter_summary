import 'package:flutter/material.dart';

typedef _Predicate<T> = bool Function(T value);
typedef _ReplaceCheck<T> = bool Function(T oldValue, T newValue);

/**
 * 二叉树节点的平衡因子A的被定义为高度差（右子树高度-左子树高度）
 * 如果二叉搜索树所有节点的平衡因子在{-1,0,1}范围内，则称为AVL树
 * 如果节点平衡因子 < 0，被称为“左重”；如果节点平衡因子 > 0，被称为“右重”；如果节点平衡因子 == 0， 有时简称为“平衡”
 */
/// AVL树节点
class _AVLTreeNode<K, Node extends _AVLTreeNode<K, Node>> {
  final K key;

  ///平衡因子，新节点没有子树，所以平衡因子为0
  int factor = 0;

  Node left;
  Node right;
  Node parent;

  _AVLTreeNode(this.key);
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

  ///插入
  ///node：新插入的节点
  ///root：指定查找的根结点，如果root不为null，则node会插入在root的子树上
  ///replaceIfExist：如果存在与node的key相等的节点，则通过replaceIfExist判断是否用node代替已有节点，
  ///如果replaceIfExist不为null且返回true则代替，否则不代替
  void _insert(Node node, {Node root, _ReplaceCheck<K> replaceIfExist}) {
    if (_root == null)
      _root = node;
    else {
      var compare = _compare;
      int comp;

      void add(Node parent) {
        comp = compare(node.key, parent.key);
        if (comp == 0) {
          if (replaceIfExist?.call(parent.key, node.key) == true) {
            ///用node替换parent
            _replaceNode(parent, node);
          }
        } else if (comp < 0) {
          if (parent.left != null) {
            add(parent.left);
          } else {
            parent.left = node;
          }
        } else {
          if (parent.right != null) {
            add(parent.right);
          } else {
            parent.right = node;
          }
        }
      }

      add(root ?? _root);
    }
  }

  ///node刚通过_insert方法插入的节点
  void _rebalanceForInsert(Node node) {
    Node parentOfUnbalancedSubtree;
    Node rootAfterRotate;
    for (Node nodeParent = node.parent; nodeParent != null; nodeParent = node.parent) {
      // 往上遍历，可能到_root
      // 节点的平衡因子factor需要被更新
      if (node == nodeParent.right) {
        // 增加节点的是右子树
        if (nodeParent.factor > 0) {
          // nodeParent右重
          // nodeParent的临时平衡因子是 +2
          // 需要重新平衡
          parentOfUnbalancedSubtree = nodeParent.parent; // Save parent of nodeParent around rotations
          if (node.factor < 0) // Right Left Case ，右左情况
            rootAfterRotate = rotateRightLeft(nodeParent, node); // Double rotation: Right(node) then Left(nodeParent)
          else // Right Right Case，右右情况
            rootAfterRotate = rotateLeft(nodeParent, node); // Single rotation Left(nodeParent)
          // After rotation adapt parent link
        } else {
          if (nodeParent.factor < 0) {
            nodeParent.factor = 0; // node’s height increase is absorbed at nodeParent.
            break; // Leave the loop
          }
          nodeParent.factor = 1;
          node = nodeParent; // Height(node) increases by 1，node高度增加了 1
          continue;
        }
      } else {
        // 增加节点的是左子树
        if (nodeParent.factor < 0) {
          // nodeParent左重
          // nodeParent的临时平衡因子是 +2
          // 需要重新平衡
          parentOfUnbalancedSubtree = nodeParent.parent; // Save parent of nodeParent around rotations
          if (node.factor > 0) // Left Right Case，左右情况
            rootAfterRotate = rotateLeftRight(nodeParent, node); // Double rotation: Left(node) then Right(nodeParent)
          else // Left Left Case，左左情况
            rootAfterRotate = rotateRight(nodeParent, node); // Single rotation Right(nodeParent)
          // After rotation adapt parent link
        } else {
          if (nodeParent.factor > 0) {
            nodeParent.factor = 0; // node’s height increase is absorbed at nodeParent.
            break; // Leave the loop
          }
          nodeParent.factor = -1;
          node = nodeParent; // Height(node) increases by 1，node高度增加了 1
          continue;
        }
      }
      // 给旋转以后的子树的根结点重新设置父节点
      // Height does not change: Height(rootAfterRotate) == old Height(nodeParent)
      rootAfterRotate.parent = parentOfUnbalancedSubtree;
      if (parentOfUnbalancedSubtree != null) {
        if (nodeParent == parentOfUnbalancedSubtree.left)
          parentOfUnbalancedSubtree.left = rootAfterRotate;
        else
          parentOfUnbalancedSubtree.right = rootAfterRotate;
      } else
        _root = rootAfterRotate; // N is the new root of the total tree
      break;
      // There is no fall thru, only break; or continue;
    }
// Unless loop is left via break, the height of the total tree increases by 1.
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
  Node rotateLeft(Node X, Node Z) {
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

  ///对应于右左情况的旋转
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
  Node rotateRightLeft(Node X, Node Z) {
    // Z is by 2 higher than its sibling
    Node Y = Z.left; // Inner child of Z
    // Y is by 1 higher than sibling
    Node t3 = Y.right;
    Z.left = t3;
    if (t3 != null)
        t3.parent = Z;
    Y.right = Z;
    Z.parent = Y;
    
    Node t2 = Y.left;
    X.right = t2;
    if (t2 != null)
        t2.parent = X;
    Y.left = X;
    X.parent = Y;
    if (Y.factor > 0) { // t3 was higher
        X.factor = -1;  // t1 now higher
        Z.factor = 0;
    } else
        if (Y.factor == 0) {
            X.factor = 0;
            Z.factor = 0;
        } else {
            // t2 was higher
            X.factor = 0;
            Z.factor = 1;  // t4 now higher
        }
    Y.factor = 0;
    return Y; // return new root of rotated subtree
}

  ///插入
  ///key: 需要删除的节点的key值
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找key删除node
  Node _delete(K key, {Node root}) {
    ///用newNode代替oldNode在oldNode.parent中的位置
    void replaceNodeInParent(Node oldNode, Node newNode) {
      if (oldNode == null) return;
      if (oldNode.parent?.left == oldNode) {
        oldNode.parent.left = newNode;
      } else if (oldNode.parent?.right == oldNode) {
        oldNode.parent.right = newNode;
      }
      oldNode.left = null;
      oldNode.right = null;
      oldNode.parent = null;
    }

    if (_root == null)
      return null;
    else {
      var compare = _compare;
      int comp;

      Node remove(Node parent) {
        if (parent == null) return null;
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

      return remove(root ?? _root);
    }
  }

  ///用newNode代替oldNode，newNode的parent、left、right都是从oldNode来
  void _replaceNode(Node oldNode, Node newNode) {
    if (oldNode == null) return;
    if (newNode != null) {
      newNode.left = oldNode.left;
      newNode.right = oldNode.right;
      newNode.parent = oldNode.parent;
    }

    if (oldNode.parent?.left == oldNode) {
      oldNode.parent.left = newNode;
    } else if (oldNode.parent?.right == oldNode) {
      oldNode.parent.right = newNode;
    }
    oldNode.left = null;
    oldNode.right = null;
    oldNode.parent = null;
  }

  ///查找node.key == key的node
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找
  Node _search(K key, {Node root}) {
    if (_root == null)
      return null;
    else {
      var compare = _compare;
      int comp;
      Node searchRecursively(Node parent) {
        if (parent == null) return null;
        comp = compare(key, parent.key);
        if (comp == 0) {
          return parent;
        } else if (comp < 0) {
          return searchRecursively(parent.left);
        } else {
          return searchRecursively(parent.right);
        }
      }

      return searchRecursively(root ?? _root);
    }
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

  void _clear() {
    _root = null;
    _count = 0;
    _modificationCount++;
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
