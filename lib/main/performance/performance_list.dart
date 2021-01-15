import 'package:flutter/material.dart';
import 'package:flutter_summary/main/performance/widgets/cupertino_alert_dialog.dart';
import 'package:flutter_summary/router/router.dart';

import 'widgets/delay_build_widget.dart';
import 'widgets/not_delay_build_widget.dart';
import 'widgets/rounded_corner_build.dart';
import 'widgets/rounded_image_page.dart';

class ListTileInfo {
  final String title;
  final VoidCallback tapAction;
  final String subTitle;

  ListTileInfo({this.title, this.tapAction, this.subTitle});
}

class PerformanceListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<ListTileInfo> itemList = [
      ListTileInfo(
          title: 'CupertinoAlertDialog',
          subTitle: 'CupertinoAlertDialog会off screen layer,打开checkerboardOffscreenLayers调试会看到弹框有颜色',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: CupertinoAlertDialogTest()));
          }),
      ListTileInfo(
          title: 'DelayBuildWidget',
          subTitle: '延时构建和图片圆角优化',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: DelayBuildWidgetTestPage()));
          }),
      ListTileInfo(
          title: 'NotDelayBuildWidget',
          subTitle: '普通页面，没优化的',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: NotDelayBuildWidget()));
          }),
      ListTileInfo(
          title: 'just RoundedImage',
          subTitle: '没有延时构建，只有图片圆角处理',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: RoundedCornderBuildPage()));
          }),
      ListTileInfo(
          title: 'RoundedImage',
          subTitle: '圆角图片',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: RoundedImagePage()));
          }),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('性能测试'),
      ),
      body: ListView.separated(
        itemBuilder: (_, index) {
          ListTileInfo info = itemList[index];
          return GestureDetector(
            onTap: info.tapAction,
            child: ListTile(
              title: Text(info.title),
              subtitle: info.subTitle != null ? Text(info.subTitle) : null,
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(
          height: 1,
        ),
        itemCount: itemList.length,
      ),
    );
  }
}
