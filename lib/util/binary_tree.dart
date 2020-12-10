import 'dart:math';

import 'package:flutter/material.dart';

///用于记录node在树中位置，以便打印出树结构
class _PrintNode extends Comparable<_PrintNode> {
  final int x;
  final int y;
  final String key;

  _PrintNode(this.x, this.y, this.key);

  @override
  int compareTo(_PrintNode other) {
    int comp = this.y.compareTo(other.y);
    if (comp != 0) {
      return comp;
    }
    return this.x.compareTo(other.x);
  }
}

///二叉树节点
class BinaryTreeNode<K, Node extends BinaryTreeNode<K, Node>> {
  final K key;

  Node left;
  Node right;
  Node parent;

  BinaryTreeNode(this.key);

  int get height {
    if (this == null) return 0;
    return 1 + max((right?.height ?? 0), (left?.height ?? 0));
  }

  String get debugString => key.toString();
}

class BinaryTreePrinter {
  static printTree(BinaryTreeNode _root) {
    List<_PrintNode> nodeList = [];
    int minX = 0;
    int treeHeight = _root?.height ?? 0;
    void traversal(BinaryTreeNode root, int x, int y, int level) {
      if (root == null) return;
      String strKey = root.debugString;
      int powNum = max(0, (treeHeight - level - 2));
      int extent = pow(2, powNum);

      int horizontalExtraSpace = pow(powNum, 2);
      nodeList.add(_PrintNode(x, y, strKey));
      if (root.left != null) {
        List.generate(extent, (index) {
          nodeList.add(_PrintNode(x - 2 - index - horizontalExtraSpace, y + 1 + index, '/'));
        });
      }
      if (root.right != null) {
        List.generate(extent, (index) {
          nodeList.add(_PrintNode(x + strKey.length + index + 1 + horizontalExtraSpace, y + 1 + index, '\\'));
        });
      }
      traversal(root.left, x - extent - 2 - horizontalExtraSpace, y + extent + 1, level + 1);
      traversal(root.right, x + extent + 2 + strKey.length + horizontalExtraSpace, y + extent + 1, level + 1);
      minX = min(x, minX);
    }

    traversal(_root, 0, 0, 0);
    nodeList.sort((a, b) => a.compareTo(b));
    String str = '';
    int currentY = 0;
    ///整体右移四个空格
    minX -= 4;
    int currentX = minX;
    int preStrLength = 0;
    nodeList.forEach((element) {
      if (currentY != element.y) {
        str += '\n';
        currentY = element.y;
        currentX = minX;
        List.generate(element.x - currentX, (index) => str += ' ');
        preStrLength = element.key.length;
      } else {
        List.generate(max(element.x - currentX - preStrLength, 1), (index) => str += ' ');
        preStrLength = element.key.length;
      }

      str += element.key;
      currentX = element.x;
    });
    debugPrint(str);
  }
}
