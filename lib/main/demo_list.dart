import 'package:flutter/material.dart' hide Router;
import 'package:flutter_summary/main/counter/counter.dart';
import 'package:flutter_summary/main/provider_counter/provider_counter.dart';
import 'package:flutter_summary/router/router.dart';

import 'china_region_select/china_region_select.dart';
import 'hit_test/hit_test_manager.dart';
import 'list_data/list_data_page.dart';
import 'order_task_manager/order_task_page.dart';
import 'parentdata_widget/parent_data_widget_demo.dart';
import 'widget_loading/widget_loading_page.dart';

class DemoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<ItemInfo> itemList = [
      ItemInfo(
          title: 'bloc 使用用例',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: Counter()));
          }),
      ItemInfo(
          title: 'provider 使用用例',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: ProviderCounter()));
          }),
      ItemInfo(
          title: '省市区选择',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: ChinaRegionSelectPage()));
          }),
      ItemInfo(
          title: '列表数据缓存和预加载',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: ListDataPage()));
          }),
      ItemInfo(
          title: '按顺序执行的步骤管理',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: OrderTaskPage()));
          }),
      ItemInfo(
          title: '在小部件上loading',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: WidgetLoading()));
          }),
      ItemInfo(
          title: 'ParenDataWidget用例',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: ParentDataWidgetDemo()));
          }),
      ItemInfo(
          title: 'hitTest',
          tapAction: () {
            Navigator.push(context, Router.routeForPage(page: HitTestManager()));
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
