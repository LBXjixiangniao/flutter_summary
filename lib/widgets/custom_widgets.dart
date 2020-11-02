import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/widgets.dart';

// //圆形头像,如果headFile不为null则忽略url
// Widget userHead({@required String url, VoidCallback onTap, PickedFile headFile, double size = 40}) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//         width: size,
//         height: size,
//         decoration: ShapeDecoration(
//             color: Colors.white,
//             shape: CircleBorder(side: BorderSide(width: 0, color: Color.fromRGBO(198, 164, 133, 1)))),
//         child: ClipRRect(
//           borderRadius: BorderRadius.all(Radius.circular(size / 2)),
//           child: headFile != null
//               ? Image.file(
//                   File(headFile.path),
//                   fit: BoxFit.cover,
//                 )
//               : FadeInImage(
//                   fit: BoxFit.cover,
//                   image: NetworkImage(url ?? '0'),
//                   placeholder: AssetImage(R.assetsImagesIconIconUserDefaultHead),
//                 ),
//         )),
//   );
// }

// Widget emptyDataWidget({double top, double bottom, Color bgColor = Colors.white}) {
//   return Container(
//     color: bgColor,
//     padding: EdgeInsets.only(top: top ?? 0, bottom: bottom ?? 0),
//     child: Center(child: Image.asset(R.assetsImagesBackgroundBgEmptyData)),
//   );
// }

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

class DisposeWidget extends StatefulWidget {
  Widget child;
  VoidCallback dispose;
  DisposeWidget({this.child, this.dispose});
  @override
  _DisposeWidgetState createState() => _DisposeWidgetState();
}

class _DisposeWidgetState extends State<DisposeWidget> {
  @override
  void dispose() {
    // TODO: implement dispose
    if (widget.dispose != null) {
      widget.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
