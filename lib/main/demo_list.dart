import 'package:flutter/material.dart';
import 'package:flutter_summary/main/counter/counter.dart';
import 'package:flutter_summary/router/router.dart';

class DemoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<ItemInfo> itemList = [
      ItemInfo(
          title: 'bloc 使用用例',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: Counter()));
          }),
    ];
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('demo list'),
      ),
      body: ListView.separated(
          itemBuilder: (_, index) {
            ItemInfo info = itemList[index];
            return GestureDetector(
              onTap: info.tapAction,
              child: Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Text(info.title),
              ),
            );
          },
          separatorBuilder: (_, __) => Divider(
                height: 1,
              ),
          itemCount: itemList.length),
    );
  }
}

class ItemInfo {
  final String title;
  final VoidCallback tapAction;

  ItemInfo({this.title, this.tapAction});
}
