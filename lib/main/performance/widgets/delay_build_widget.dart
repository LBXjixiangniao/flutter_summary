import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
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
    super.initState();
    manager = DelayBuildManager(reverse: true);
  }

  @override
  Widget item(GridInfo info, {bool useRoundCornerImageProvider = false}) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return DelayBuildChild(
          index: info.index,
          buildManager: manager,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: super.item(info, useRoundCornerImageProvider: true),
        );
      },
    );
  }
}

enum _BuildStatus {
  idle,
  layout,
  paint,
}

class DelayBuildChild extends SingleChildRenderObjectWidget {
  final DelayBuildManager buildManager;
  final double width;
  final double height;
  final bool addRepaintBoundary;
  final int index;
  DelayBuildChild({
    Key key,
    Widget child,
    this.buildManager,
    this.width,
    this.height,
    this.index,
    this.addRepaintBoundary = true,
  })  : assert(width != null && height != null && addRepaintBoundary != null),
        super(key: key, child: child);

  @override
  _BuildControlRenderObject createRenderObject(BuildContext context) {
    return _BuildControlRenderObject(
      buildManager: buildManager,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
      index: index,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant _BuildControlRenderObject renderObject) {
    renderObject.buildManager = buildManager;
    renderObject.width = width;
    renderObject.height = height;
    renderObject.addRepaintBoundary = addRepaintBoundary;
    renderObject.index = index;
  }

  @override
  void didUnmountRenderObject(covariant _BuildControlRenderObject renderObject) {
    renderObject.info.tryUnlink();
    super.didUnmountRenderObject(renderObject);
  }
}

class _BuildControlRenderObject extends RenderProxyBox {
  BuildInfo info;
  DelayBuildManager buildManager;
  double width;
  double height;
  bool addRepaintBoundary;
  int index;
  _BuildControlRenderObject({
    this.buildManager,
    this.width,
    this.height,
    this.addRepaintBoundary,
    this.index,
  }) : assert(width != null && height != null) {
    info = BuildInfo(markNeedsLayout: () {
      if (this.attached) {
        print('markNeedsLayout $index');
        super.markNeedsLayout();
      }
    }, markNeedsPaint: () {
      if (this.attached) {
        print('markNeedsPaint $index');
        if (index == 9) {
          print('here');
        }

        super.markNeedsPaint();
      }
    });
  }

  @override
  void attach(covariant PipelineOwner owner) {
    print('attach $index');
    super.attach(owner);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    // TODO: implement toString
    return index.toString();
  }

  @override
  bool get isRepaintBoundary => addRepaintBoundary;

  @override
  Size get size => Size(width, height);

  @override
  void detach() {
    info.tryUnlink();
    super.detach();
  }

  @override
  void markNeedsLayout() {
    if (info.currentStatus != _BuildStatus.layout) {
      info.nextStatus = _BuildStatus.layout;
      addBuildInfoToManager();
    }
  }

  @override
  void performLayout() {
    if (info.currentStatus == _BuildStatus.layout) {
      print('performLayout $index');
      super.performLayout();
    } else {
      performResize();
    }
  }

  // @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    print('layout $index');
    super.layout(BoxConstraints.tight(Size(width, height)), parentUsesSize: false);
  }

  @override
  void markNeedsPaint() {
    if (info.currentStatus == _BuildStatus.idle && info.nextStatus == _BuildStatus.idle) {
      info.nextStatus = _BuildStatus.paint;
      addBuildInfoToManager();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (info.list == null || info.currentStatus == _BuildStatus.paint) {
      print('paint $index');
      super.paint(context, offset);
    }
  }

  void addBuildInfoToManager() {
    if (info.list == null) {
      (buildManager ?? _delayBuildManager)._add(info);
    }
  }
}

DelayBuildManager _delayBuildManager = DelayBuildManager(reverse: true);

class DelayBuildManager {
  final LinkedList<BuildInfo> _list = LinkedList<BuildInfo>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  //是否后加入的事件先执行
  final bool reverse;

  DelayBuildManager({this.reverse = false});
  void _add(BuildInfo info) {
    _list.add(info);
    if (!_isRunning) {
      _isRunning = true;
      ServicesBinding.instance.scheduleTask(() {
        print('*************** scheduleTask');
      }, Priority.idle);
      // ServicesBinding.instance.scheduleTask(() {
      //   print('scheduleTask');
      // }, Priority.animation);
      // ServicesBinding.instance.scheduleTask(() {
      //   print('scheduleTask');
      // }, Priority.touch);
      ServicesBinding.instance.addPostFrameCallback((_) {
        _actionNext();
      });
    }
  }

  void _actionNext() {
    if (_list.isNotEmpty) {
      _isRunning = true;
      BuildInfo info = reverse == true ? _list.last : _list.first;
      if (info.nextStatus == _BuildStatus.idle || info.nextStatus == null) {
        info.currentStatus = _BuildStatus.idle;
        info.tryUnlink();
        _actionNext();
      } else {
        if (info.nextStatus == _BuildStatus.layout) {
          info.currentStatus = _BuildStatus.layout;
          info.nextStatus = _BuildStatus.paint;
          info.markNeedsLayout();
        } else if (info.nextStatus == _BuildStatus.paint) {
          info.currentStatus = _BuildStatus.paint;
          info.nextStatus = _BuildStatus.idle;
          info.markNeedsPaint();
        }

        ServicesBinding.instance.addPostFrameCallback((_) {
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
