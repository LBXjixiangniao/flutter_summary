import 'package:flutter/material.dart';
import 'package:list_index_manager/list_index_manager.dart';

class IndexManagerPage extends StatefulWidget {
  @override
  _IndexManagerPageState createState() => _IndexManagerPageState();
}

class _IndexManagerPageState extends State<IndexManagerPage> {
  List<Info> dataList = [];
  ListIndexManager manager = ListIndexManager();
  @override
  void initState() {
    super.initState();
    List.generate(5, (index) {
      dataList.add(Info(groupId: 'one', value: index, isFirst: index == 0));
    });

    List.generate(8, (index) {
      dataList.add(Info(groupId: 'two', value: index + 5, isFirst: index == 0));
    });

    List.generate(3, (index) {
      dataList.add(Info(groupId: 'three', value: index + 13, isFirst: index == 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('测试'),
      ),
      body: ListView.builder(
        itemCount: dataList.length - manager.totalHideNumber,
        itemBuilder: (_, index) {
          Info info = dataList[manager.indexOf(index)];
          if (info.isFirst) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    int start;
                    int end;
                    if (info.groupId == 'one') {
                      start = 1;
                      end = 4;
                    } else if (info.groupId == 'two') {
                      start = 6;
                      end = 12;
                    } else if (info.groupId == 'three') {
                      start = 14;
                      end = 15;
                    }
                    setState(() {
                      if (info.isOpen) {
                        manager.hideRange(start, end);
                      } else {
                        manager.showRange(start, end);
                      }
                      info.isOpen = !info.isOpen;
                    });
                  },
                  child: Container(
                    height: 44,
                    width: BoxConstraints.expand().maxWidth,
                    color: Colors.red,
                    child: Text(
                      info.groupId,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (info.isOpen)
                  ListTile(
                    title: Text(info.groupId),
                    subtitle: Text(info.value.toString()),
                  )
              ],
            );
          }
          return ListTile(
            title: Text(info.groupId),
            subtitle: Text(info.value.toString()),
          );
        },
      ),
    );
  }
}

class Info {
  final String groupId;
  final int value;
  bool isOpen = true;
  final bool isFirst;
  Info({this.groupId, this.value, this.isFirst = false});
}