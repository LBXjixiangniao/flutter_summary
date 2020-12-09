import 'package:flutter/material.dart';
import 'package:flutter_summary/util/avl_tree.dart';

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
      body: Column(
        children: [
          TextField(
            controller: textEditingController,
            keyboardType: TextInputType.number,
          ),
          FlatButton(
            child: Text('增加'),
            onPressed: () {
              treeSet.add(int.parse(textEditingController.text));
            },
          ),
          FlatButton(
            child: Text('删除'),
            onPressed: () {},
          ),
          FlatButton(
            child: Text('查找'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
