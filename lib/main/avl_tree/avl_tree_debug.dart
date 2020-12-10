import 'package:flutter/material.dart';
import 'package:flutter_summary/util/avl_tree.dart';
import 'package:flutter_summary/util/binary_tree.dart';

class AVLTreeDebugPage extends StatefulWidget {
  @override
  _AVLTreeDebugPageState createState() => _AVLTreeDebugPageState();
}

class _AVLTreeDebugPageState extends State<AVLTreeDebugPage> {
  AVLTreeSet<int> treeSet = AVLTreeSet<int>();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    treeSet.debug = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AVL树验证'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: TextField(
              controller: textEditingController,
              keyboardType: TextInputType.number,
            ),
          ),
          Container(
            height: 44,
            alignment: Alignment.center,
            child: Text('${treeSet.length}'),
          ),
          FlatButton(
            child: Text('增加'),
            onPressed: () {
              treeSet.add(int.parse(textEditingController.text));
              setState(() {
                
              });
            },
          ),
          FlatButton(
            child: Text('删除'),
            onPressed: () {
              treeSet.remove(int.parse(textEditingController.text));
              setState(() {
                
              });
            },
          ),
          FlatButton(
            child: Text('查找'),
            onPressed: () {
              treeSet.contains(int.parse(textEditingController.text));
              setState(() {
                
              });
            },
          ),
          FlatButton(
            child: Text('打印树结构'),
            onPressed: () {
              treeSet.debugPrint();
            },
          ),
        ],
      ),
    );
  }
}
