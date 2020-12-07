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
  void insert(Node node, {Node root, _ReplaceCheck<K> replaceIfExist}) {
    if (_root == null)
      _root = node;
    else {
      var compare = _compare;
      int comp;
      void add(Node parent) {
        comp = compare(node.key, parent.key);
        if (comp == 0) {
          if (replaceIfExist?.call(parent.key, node.key) == true) {

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

  Node get _first {
    // var root = _root;
    // if (root == null) return null;
    // _root = _splayMin(root);
    // return _root;
  }

  Node get _last {
    // var root = _root;
    // if (root == null) return null;
    // _root = _splayMax(root);
    // return _root;
  }

  void _clear() {
    _root = null;
    _count = 0;
    _modificationCount++;
  }
}
