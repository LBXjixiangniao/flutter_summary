import 'dart:math';

import 'package:flutter/material.dart';

///用于记录node在树中位置，以便打印出树结构
class _PrintNode extends Comparable<_PrintNode> {
  final int positionX;
  final int y;
  final int x;
  final String key;

  _PrintNode({@required this.positionX, @required this.x, @required this.y, @required this.key});

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
  static String treeStructureString(BinaryTreeNode _root) {
    List<_PrintNode> nodeList = [];
    int minX = 0;
    int treeHeight = _root?.height ?? 0;
    void traversal({BinaryTreeNode root, int positionX, int x, int y, int level}) {
      if (root == null) return;
      String strKey = root.debugString;
      int powNum = max(0, (treeHeight - level - 2));
      int verticalExtent = pow(2, powNum).toInt();
      int horizontalExtraSpace = pow(2.5, powNum).toInt();
      nodeList.add(_PrintNode(positionX: positionX, x: x, y: y, key: strKey));
      if (root.left != null) {
        List.generate(verticalExtent, (index) {
          nodeList.add(
            _PrintNode(
              positionX: positionX - index - horizontalExtraSpace,
              x: x - 1 - index,
              y: y + 1 + index,
              key: '/',
            ),
          );
        });
      }
      if (root.right != null) {
        List.generate(verticalExtent, (index) {
          nodeList.add(_PrintNode(
              positionX: positionX + strKey.length + index + horizontalExtraSpace,
              x: x + 1 + index,
              y: y + 1 + index,
              key: '\\'));
        });
      }

      int xExtent = pow(3, powNum);
      traversal(
          root: root.left,
          positionX: positionX - verticalExtent - horizontalExtraSpace - strKey.length ~/ 2,
          x: x - 1 - xExtent,
          y: y + verticalExtent + 1,
          level: level + 1);
      traversal(
          root: root.right,
          positionX: positionX + verticalExtent + strKey.length + horizontalExtraSpace - strKey.length ~/ 2,
          x: x + 1 + xExtent,
          y: y + verticalExtent + 1,
          level: level + 1);
      minX = min(positionX, minX);
    }

    traversal(root: _root, positionX: 0, x: 0, y: 0, level: 0);
    nodeList.sort((a, b) => a.compareTo(b));
    String str = '';
    int currentY;

    ///整体右移四个空格
    minX -= 4;

    String line = '';
    nodeList.forEach((element) {
      if (currentY != element.y) {
        str += '\n' + line;
        currentY = element.y;
        line = '';
        List.generate(max(element.positionX - minX, 1), (index) => line += ' ');
      } else {
        List.generate(max(element.positionX - minX - line.length, 1), (index) => line += ' ');
      }

      line += element.key;
    });
    str += '\n' + line;
    return str;
  }

  static printTree(BinaryTreeNode _root) {
    debugPrint(treeStructureString(_root));
  }
}
