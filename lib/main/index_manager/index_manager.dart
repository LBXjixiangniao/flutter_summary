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
        itemBuilder: (_, index) {},
        itemCount: 0,
      ),
    );
  }
}

class GroupIndexManager {
  SplayTreeMap<GroupKey, GroupInfo> _treeMap = SplayTreeMap<GroupKey, GroupInfo>((a, b) {
    return 0;
  });

  void closeGroup(String groupId) {
    assert(groupId != null);
    GroupInfo info = _treeMap[GroupKey(groupId: groupId)];
    info.isOpen = false;
  }

  void openGroup(String groupId) {
    assert(groupId != null);
    GroupInfo info = _treeMap[GroupKey(groupId: groupId)];
    info.isOpen = true;
  }

  int indexOf(int index) {
    assert(index != null);
    GroupInfo info = _treeMap[GroupKey(startIndex: index)];
    
  }

  bool add(String groupId, {RangeValues rage}) {

  }

  bool remove(String groupId, {RangeValues rage}) {
    
  }
}

class GroupInfo {
  int dataStartIndex;
  int length;
  String groupId;
  bool isOpen;
}

class GroupKey extends Comparable<GroupKey> {
  int startIndex;
  int dataStartIndex;
  String groupId;
  GroupKey({this.startIndex, this.dataStartIndex, this.groupId})
      : assert(startIndex != null || dataStartIndex != null || groupId != null);

  @override
  int compareTo(other) {
    if (startIndex != null && other.startIndex != null) {
      return startIndex.compareTo(other.startIndex);
    }
    if (dataStartIndex != null && other.dataStartIndex != null) {
      return dataStartIndex.compareTo(other.dataStartIndex);
    }
    if (groupId != null && other.groupId != null) {
      return groupId.compareTo(other.groupId);
    }
    return 0;
  }
}
