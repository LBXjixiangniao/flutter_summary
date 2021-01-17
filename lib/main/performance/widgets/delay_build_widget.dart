import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'not_delay_build_widget.dart';

class DelayBuildWidgetTestPage extends NotDelayBuildWidget {
  @override
  _DelayBuildWidgetTestPageState createState() => _DelayBuildWidgetTestPageState();
}

class _DelayBuildWidgetTestPageState extends NotDelayBuildWidgetState {
  @override
  String get pageTitle => '延时构建小部件测试';
  DelayBuildManager manager;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    manager = DelayBuildManager();
  }

  @override
  Widget item(GridInfo info, {bool useRoundCornerImageProvider = false}) {
    // TODO: implement item
    return DelayBuildChild(
      // placeholder: Container(
      //   color: Colors.red,
      // ),
      buildManager: manager,
      index: info.index,

      child: super.item(info, useRoundCornerImageProvider: true),
    );
  }
}

/**
 * DelayBuildChild的child会延时build
 * placeholder：child还没build的时候显示
 * buildManager：用于管理延时build，不传递该参数就使用默认的_delayBuildManager管理
 */
// class DelayBuildChild extends StatefulWidget {
//   final int index;
//   final Widget child;
//   final Widget placeholder;
//   final DelayBuildManager buildManager;
//   DelayBuildChild({Key key, this.child, this.placeholder, this.buildManager,this.index}) : super(key: key);

//   @override
//   _DelayBuildChildState createState() => _DelayBuildChildState();
// }

// class _DelayBuildChildState extends State<DelayBuildChild> {
//   bool canBuild = false;
//   BuildInfo info;
//   DelayBuildManager buildManager;

//   @override
//   void dispose() {
//     super.dispose();
//     info.valid = false;
//   }

//   @override
//   void initState() {
//     super.initState();
//     print('============initState ${widget.index}');
//     createInfoAndAddToBuildStack();
//   }

//   @override
//   void didUpdateWidget(covariant DelayBuildChild oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     info.valid = false;
//     canBuild = false;
//     createInfoAndAddToBuildStack();
//   }

//   void createInfoAndAddToBuildStack() {
//     info = BuildInfo(
//       rebuild: () {
//         if (mounted) {
//           setState(() {
//             canBuild = true;
//           });
//         }
//       },
//     );
//     buildManager = widget.buildManager ?? _delayBuildManager;
//     buildManager._add(info);
//   }

//   @override
//   Widget build(BuildContext context) {
//     AnimatedOpacity
//     return BuildControlWidget(
//       child: widget.child,
//       canBuild: canBuild,
//     );
//   }
// }

enum _BuildStatus {
  idle,
  layout,
  paint,
}

class DelayBuildChild extends SingleChildRenderObjectWidget {
  int index;
  final DelayBuildManager buildManager;
  final bool canBuild;
  DelayBuildChild({Key key, Widget child, this.canBuild, this.index, this.buildManager}) : super(key: key, child: child);

  @override
  BuildControlRenderObject createRenderObject(BuildContext context) {
    return BuildControlRenderObject(index: index, buildManager: buildManager);
  }

  @override
  void updateRenderObject(BuildContext context, covariant BuildControlRenderObject renderObject) {
    renderObject.index = index;
    renderObject.buildManager = buildManager;
  }

  @override
  SingleChildRenderObjectElement createElement() {
    return super.createElement();
  }
}

class BuildControlRenderObject extends RenderProxyBox {
  int index;
  BuildInfo info;
  DelayBuildManager buildManager;
  BuildControlRenderObject({this.index, this.buildManager}) {
    info = BuildInfo(markNeedsLayout: (){
      super.markNeedsLayout();
      // super.performLayout();
    }, markNeedsPaint: super.markNeedsPaint);
  }

  // @override
  // Size get size => (info.currentStatus == _BuildStatus.idle && !hasSize) ? Size(100,100) : super.size;

  @override
  void markNeedsLayout() {
    print('markNeedsLayout $index ${info.currentStatus}');
    if (info.currentStatus != _BuildStatus.layout) {
      info.nextStatus = _BuildStatus.layout;
      addBuildInfoToManager();
    }
    // super.markNeedsLayout();
  }

  @override
  void performLayout() {
    print('performLayout $index ${info.currentStatus}');
    if (info.currentStatus == _BuildStatus.layout) {
      super.performLayout();
    }
     else {
      performResize();
    }
  }

  // @override
  // void layout(Constraints constraints, {bool parentUsesSize = false}) {
  //   print('layout $index ${info.currentStatus}');
  //   if (info.currentStatus == _BuildStatus.layout) {
  //     super.layout(constraints, parentUsesSize: parentUsesSize);
  //   }
  // }

  @override
  void markNeedsPaint() {
    print('markNeedsPaint $index ${info.currentStatus}');
    if (info.currentStatus == _BuildStatus.idle && info.nextStatus == _BuildStatus.idle) {
      info.nextStatus = _BuildStatus.paint;
      addBuildInfoToManager();
    }
    // super.markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    print('paint $index ${info.currentStatus}');
    if (info.currentStatus == _BuildStatus.paint) {
      super.paint(context, offset);
    }
  }

  void addBuildInfoToManager() {
    info.tryUnlink();
    (buildManager ?? _delayBuildManager)._add(info);
  }
}

DelayBuildManager _delayBuildManager = DelayBuildManager();

class DelayBuildManager {
  final LinkedList<BuildInfo> _list = LinkedList<BuildInfo>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  DelayBuildManager();
  void _add(BuildInfo info) {
    _list.add(info);
    if (!_isRunning) {
      _isRunning = true;
      ServicesBinding.instance.addPostFrameCallback((_) {
        print('frame callback');
        _actionNext();
      });
    }
  }

  void _actionNext() {
    if (_list.isNotEmpty) {
      _isRunning = true;
      BuildInfo info = _list.last;
      if (info.nextStatus == _BuildStatus.idle || info.nextStatus == null) {
        info.currentStatus = _BuildStatus.idle;
        info.tryUnlink();
        _actionNext();
      } else {
        if (info.nextStatus == _BuildStatus.layout) {
          info.currentStatus = _BuildStatus.layout;
          info.nextStatus = _BuildStatus.paint;
          print('markNeedsLayout');
          info.markNeedsLayout();
        } else if (info.nextStatus == _BuildStatus.paint) {
          info.currentStatus = _BuildStatus.paint;
          info.nextStatus = _BuildStatus.idle;
          print('markNeedsPaint');
          info.markNeedsPaint();
        }
        ServicesBinding.instance.addPostFrameCallback((_) {
          print('frame callback');
          _actionNext();
        });
      }
    } else {
      _isRunning = false;
    }
  }
}

class BuildInfo extends LinkedListEntry<BuildInfo> {
  _BuildStatus nextStatus;
  _BuildStatus currentStatus;
  final VoidCallback markNeedsLayout;
  final VoidCallback markNeedsPaint;

  BuildInfo({
    @required this.markNeedsLayout,
    @required this.markNeedsPaint,
    this.currentStatus = _BuildStatus.idle,
    this.nextStatus = _BuildStatus.idle,
  }) : assert(markNeedsLayout != null, markNeedsPaint != null);

  void tryUnlink() {
    if (list != null) unlink();
  }
}
