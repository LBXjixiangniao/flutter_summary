import 'dart:collection';

import 'package:flutter/material.dart';

class IndexManagerPage extends StatefulWidget {
  @override
  _IndexManagerPageState createState() => _IndexManagerPageState();
}

class _IndexManagerPageState extends State<IndexManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分组列表的下标管理'),
      ),
      body: ListView.builder(
        itemBuilder: (_, index) {

        },
        itemCount: 0,
      ),
    );
  }
}

class IndexManager {
  SplayTreeSet<IndexManagerItem> _treeSet = SplayTreeSet<IndexManagerItem>((a,b){
    return 0;
  });


}

class IndexManagerItem {
  int startIndex;
  // final int originStartIndex;
  // final int originEndIndex;
  // final CallbackAction a;
}
