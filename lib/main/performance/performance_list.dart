import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/main/performance/widgets/cupertino_alert_dialog.dart';
import 'package:flutter_summary/router/router.dart';

import 'widgets/create_rounder_corner_image.dart';
import 'widgets/customLayout.dart';
import 'widgets/not_rounded_image.page.dart';
import 'widgets/optimize_widget.dart';
import 'widgets/common_widget.dart';
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
          title: '普通页面',
          subTitle: '普通页面，没优化的',
          tapAction: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CommonPage()));
          }),
      ListTileInfo(
          title: '优化页面',
          subTitle: 'layout和paint分帧进行',
          tapAction: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => OptimizePage()));
          }),
      ListTileInfo(
          title: 'RoundedImage',
          subTitle: 'ClipRRect圆角图片',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: RoundedImagePage()));
          }),
      ListTileInfo(
          title: 'NotRoundedImage',
          subTitle: '非圆角图片',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: NotRoundedImagePage()));
          }),
      ListTileInfo(
          title: '创建圆角',
          subTitle: 'ImageProvider生成带圆角的图片',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: CustomRoundedImagePage()));
          }),
      ListTileInfo(
          title: '自定义layout',
          subTitle: '自定义layout',
          tapAction: () {
            Navigator.push(context, RouterManager.routeForPage(page: CustomLayoutPage()));
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
