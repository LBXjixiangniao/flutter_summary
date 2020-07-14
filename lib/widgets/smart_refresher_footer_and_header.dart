import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

Widget defaultRefreshFooter() {
  return ClassicFooter(
    loadingText: '正在加载',
    idleText: '上拉加载更多',
    noDataText: '无更多数据',
    failedText: '加载失败',
    canLoadingText: '松开加载数据',
  );
}

Widget defaultRefreshHeader({double safeAreaTop = 0, Color bgColor}) {
  return ClassicHeader(
      outerBuilder: (safeAreaTop != null && safeAreaTop > 0) || bgColor != null
          ? (child) {
              return Container(
                color: bgColor,
                height: 60 + safeAreaTop,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.bottomCenter,
                child: child,
              );
            }
          : null,
      height: 60 + safeAreaTop ?? 0,
      refreshingText: '正在加载',
      idleText: '下拉刷新数据',
      failedText: '刷新失败',
      releaseText: '松开刷新数据',
      completeText: '加载完成');
}