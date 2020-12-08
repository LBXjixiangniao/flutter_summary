import 'dart:html';

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
      _rebalanceForInsert(node);
    }
  }

  ///Z刚通过_insert方法插入的节点
  void _rebalanceForInsert(Node Z) {
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
            N = rotateRightLeft(X, Z); // Double rotation: Right(Z) then Left(X)
          else // Right Right Case    (see figure 4)
            N = rotateLeft(X, Z); // Single rotation Left(X)
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
            N = rotateLeftRight(X, Z); // Double rotation: Left(Z) then Right(X)
          else // Left Left Case
            N = rotateRight(X, Z); // Single rotation Right(X)
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

  ///插入
  ///key: 需要删除的节点的key值
  ///root：指定查找的根结点，如果root不为null，则会从root开始查找key删除node
  Node _delete(K key, {Node root}) {
    ///用newNode代替oldNode在oldNode.parent中的位置,_delete方法中只有此处才可能导致子树高度减一
    ///所以在此方法中判断是否需要重新平衡即可
    void replaceNodeInParent(Node oldNode, Node newNode) {
      if (oldNode == null) return;

      if (oldNode.parent?.left == oldNode) {
        oldNode.parent.left = newNode;
      } else if (oldNode.parent?.right == oldNode) {
        oldNode.parent.right = newNode;
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
        ///newNode == null
        if (oldNode.parent?.left == oldNode) {
          if (oldNode.parent.factor == 0) {
            oldNode.parent.factor = 1;
          } else if (oldNode.parent.factor == -1) {
            oldNode.parent.factor = 0;
            _rebalanceForDelete(oldNode.parent);
          } else if (oldNode.parent.factor == 1) {
            ///oldNode.parent暂时平衡因子是2
            Node rightNode = oldNode.parent.right;
            if (rightNode.factor == 0) {
              //右右、右左处理都行，处理完之后oldNode.parent子树高度不变，不用再次平衡
              //右右需要旋转次数少，所以此处当左左处理
              rotateLeft(rightNode.parent, rightNode);
            } else if (rightNode.factor == 1) {
              ///右右情形
              rotateLeft(rightNode.parent, rightNode);

              ///oldNode.parent子树高度减1，需要重新平衡
              _rebalanceForDelete(oldNode.parent);
            } else if (rightNode.factor == -1) {
              ///右左情形
              rotateRightLeft(rightNode.parent, rightNode);

              ///oldNode.parent子树高度减1，需要重新平衡
              _rebalanceForDelete(oldNode.parent);
            }
          }
        } else if (oldNode.parent?.right == oldNode) {
          if (oldNode.parent.factor == 0) {
            oldNode.parent.factor = -1;
          } else if (oldNode.parent.factor == 1) {
            oldNode.parent.factor = 0;
            _rebalanceForDelete(oldNode.parent);
          } else if (oldNode.parent.factor == -1) {
            ///oldNode.parent暂时平衡因子是-2
            Node leftNode = oldNode.parent.left;
            if (leftNode.factor == 1) {
              //左右、左左处理都行，处理完之后oldNode.parent子树高度不变，不用再次平衡
              //左左需要旋转次数少，所以此处当左左处理
              rotateRight(leftNode.parent, leftNode);
            } else if (leftNode.factor == 1) {
              ///左右情形
              rotateLeftRight(leftNode.parent, leftNode);

              ///oldNode.parent子树高度减1，需要重新平衡
              _rebalanceForDelete(oldNode.parent);
            } else if (leftNode.factor == -1) {
              ///左左情形
              rotateRight(leftNode.parent, leftNode);

              ///oldNode.parent子树高度减1，需要重新平衡
              _rebalanceForDelete(oldNode.parent);
            }
          }
        }
      }
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

      Node deletedNode = remove(root ?? _root);
      if (deletedNode != null) {
        deletedNode.left = null;
        deletedNode.right = null;
        deletedNode.parent = null;
      }
      return deletedNode;
    }
  }

  ///node为跟的子树高度降低了1，且N是已经已经平衡的AVL子树
  void _rebalanceForDelete(Node N) {
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
            N = rotateRightLeft(X, Z); // Double rotation: Right(Z) then Left(X)
          else // Right Right Case    (see figure 4)
            N = rotateLeft(X, Z); // Single rotation Left(X)
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
            N = rotateLeftRight(X, Z); // Double rotation: Left(Z) then Right(X)
          else // Left Left Case
            N = rotateRight(X, Z); // Single rotation Right(X)
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
  Node rotateRight(Node X, Node Z) {
    // Z is by 2 higher than its sibling
    Node t23 = Z.right; // Inner child of Z
    X.left = t23;
    if (t23 != null) t23.parent = X;
    Z.right = X;
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
  Node rotateRightLeft(Node X, Node Z) {
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
  Node rotateLeftRight(Node X, Node Z) {
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
