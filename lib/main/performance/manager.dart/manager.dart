import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

final DelayBuildManager defaultDelayBuildManager = DelayBuildManager(reverse: true);

enum _LayoutAndPaintStatus {
  idle,
  layout,
  paint,
}

class DelayBuildWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final DelayBuildManager buildManager;
  const DelayBuildWidget({Key key, this.buildManager, this.builder}) : super(key: key);
  @override
  _DelayBuildWidgetState createState() => _DelayBuildWidgetState();
}

class _DelayBuildWidgetState extends State<DelayBuildWidget> {
  bool _initBuild = false;
  DelayBuildManager buildManager;

  @override
  void initState() {
    buildManager = widget.buildManager ?? defaultDelayBuildManager;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DelayBuildWidget oldWidget) {
    buildManager = widget.buildManager ?? defaultDelayBuildManager;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_initBuild == false) {
      _initBuild = true;
      buildManager._add(
        _BuildAction(
          callback: () {
            if (mounted) {
              setState(() {});
            }
            return true;
          },
        ),
      );
      return SizedBox.shrink();
    }
    return widget.builder?.call(context);
  }
}

class DelayLayoutAndPaintChild extends SingleChildRenderObjectWidget {
  //用于控制DelayBuildChild的layout和paint
  final DelayBuildManager buildManager;
  //必须设置宽高，因为layout延迟了，为了不影响其他小部件layout，所以要设置固定的宽高
  final double width;
  final double height;
  //DelayBuildChild对应的RenderObject是否是repaintBoundary
  final bool addRepaintBoundary;
  DelayLayoutAndPaintChild({
    Key key,
    Widget child,
    this.buildManager,
    @required this.width,
    @required this.height,
    this.addRepaintBoundary = true,
  })  : assert(width != null && height != null),
        super(
          key: key,
          child: _LayoutAndPaintDelayMarker(
            child: child,
          ),
        );
  static DelayLayoutAndPaintChild defaultManager({
    Key key,
    Widget child,
    double width,
    double height,
    int index,
    bool addRepaintBoundary = true,
  }) {
    return DelayLayoutAndPaintChild(
      key: key,
      buildManager: defaultDelayBuildManager,
      child: child,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
    );
  }

  @override
  _LayoutAndPaintDelayElement createElement() {
    return _LayoutAndPaintDelayElement(this);
  }

  @override
  _LayoutAndPaintDelayRenderObject createRenderObject(BuildContext context) {
    _LayoutAndPaintDelayRenderObject renderObject = _LayoutAndPaintDelayRenderObject(
      buildManager: buildManager,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
    );
    if (buildManager == null) {
      //往上寻找_BuildDelayMarkerElement并获取DelayBuildManager
      _LayoutAndPaintDelayMarkerElement marker = _LayoutAndPaintDelayMarker.of(context);
      assert(marker?._buildManager != null, '如果widget的buildManager为null，则marker._buildManager不能为空');
      renderObject.buildManager = marker?._buildManager;
      renderObject._dependencyBuildInfo = marker?._info;
    }
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _LayoutAndPaintDelayRenderObject renderObject) {
    //buildManager在element中更新
    // renderObject.buildManager = buildManager;

    renderObject.width = width;
    renderObject.height = height;
    renderObject.addRepaintBoundary = addRepaintBoundary;
  }

  @override
  void didUnmountRenderObject(covariant _LayoutAndPaintDelayRenderObject renderObject) {
    renderObject.info.tryUnlink();
    super.didUnmountRenderObject(renderObject);
  }
}

class _LayoutAndPaintDelayElement extends SingleChildRenderObjectElement {
  _LayoutAndPaintDelayMarkerElement _marker;
  _LayoutAndPaintDelayElement(SingleChildRenderObjectWidget widget) : super(widget);
  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _LayoutAndPaintDelayMarker.of(this, listen: true);
  }

  @override
  _LayoutAndPaintDelayRenderObject get renderObject => super.renderObject;

  @override
  DelayLayoutAndPaintChild get widget => super.widget;

  @override
  void update(covariant DelayLayoutAndPaintChild newWidget) {
    if (newWidget.buildManager != null) {
      renderObject.buildManager = newWidget.buildManager;
      _marker?.buildManager = newWidget.buildManager;
    } else {
      resetDependentRenderObjectValue();
    }
    super.update(newWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //依赖的_BuildDelayMarker的buildManager改变的时候才会执行该处代码
    if (widget.buildManager == null) {
      //如buildManager为null，则该DelayBuildChild的layout和paint依赖于树上层的其他DelayBuildChild
      resetDependentRenderObjectValue();
    }
  }

  void resetDependentRenderObjectValue() {
    _LayoutAndPaintDelayMarkerElement marker = _LayoutAndPaintDelayMarker.of(this);
    assert(marker != null, '如果widget的buildManager为null，则marker不能为空');
    renderObject.buildManager = marker?._buildManager;

    renderObject._dependencyBuildInfo = marker?._info;
    _marker?.buildManager = marker?._buildManager;
  }
}

///用来传递DelayBuildChild的buildManager和其renderObject的BuildInfo到子树
class _LayoutAndPaintDelayMarker extends InheritedWidget {
  _LayoutAndPaintDelayMarker({
    Key key,
    Widget child,
  }) : super(key: key, child: child);
  @override
  @override
  _LayoutAndPaintDelayMarkerElement createElement() {
    return _LayoutAndPaintDelayMarkerElement(this);
  }

  static _LayoutAndPaintDelayMarkerElement of(BuildContext context, {bool listen}) {
    InheritedElement element = context.getElementForInheritedWidgetOfExactType<_LayoutAndPaintDelayMarker>();
    if (listen == true && element != null) {
      context.dependOnInheritedElement(element);
    }
    return element as _LayoutAndPaintDelayMarkerElement;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

//用来传递_BuildDelayRenderObject的info和buildManager到子树
class _LayoutAndPaintDelayMarkerElement extends InheritedElement {
  LayoutAndPaintAction _info;
  DelayBuildManager _buildManager;
  _LayoutAndPaintDelayMarkerElement(InheritedWidget widget) : super(widget);

  //同步_BuildDelayRenderObject的buildManager的更改
  set buildManager(DelayBuildManager manager) {
    DelayBuildManager oldManager = _buildManager;
    _buildManager = manager;
    if (oldManager != _buildManager) {
      notifyClients(widget);
    }
  }

  @override
  void mount(Element parent, newSlot) {
    //在super.mount(parent, newSlot)前设置DelayBuildManager和BuildInfo，以确保在子RenderObject创建的时候能回去到这两个值
    //_BuildDelayMarkerElement创建的时候parent.renderObject已经创建了
    if (parent is _LayoutAndPaintDelayElement) {
      _LayoutAndPaintDelayRenderObject parentRenderObject = parent.renderObject;
      _info = parentRenderObject.info;
      _buildManager = parentRenderObject.buildManager;
      parent._marker = this;
    }

    super.mount(parent, newSlot);
  }
}

class _LayoutAndPaintDelayRenderObject extends RenderProxyBox {
  //info依赖于_dependencyBuildInfo
  LayoutAndPaintAction _dependencyBuildInfo;

  LayoutAndPaintAction info;
  DelayBuildManager buildManager;
  double width;
  double height;
  bool addRepaintBoundary;
  //标识是否已经paint过了，因为如果还没paint过，则_needsPaint为true，这时候调用markNeedsPaint会被忽略
  bool _hadPainted = false;
  _LayoutAndPaintDelayRenderObject({
    this.buildManager,
    this.width,
    this.height,
    this.addRepaintBoundary,
  }) : assert(width != null && height != null) {
    info = LayoutAndPaintAction(markNeedsLayout: () {
      if (this.attached) {
        super.markNeedsLayout();
        return true;
      }
      return false;
    }, markNeedsPaint: () {
      if (this.attached && _hadPainted) {
        super.markNeedsPaint();
        return true;
      }
      return false;
    });
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
    if (info.currentStatus != _LayoutAndPaintStatus.layout) {
      info.nextStatus = _LayoutAndPaintStatus.layout;
      addBuildInfoToManager();
    }
  }

  @override
  void performLayout() {
    if (info.currentStatus == _LayoutAndPaintStatus.layout) {
      super.performLayout();
    } else {
      performResize();
    }
  }

  // @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    super.layout(BoxConstraints.tight(Size(width, height)), parentUsesSize: false);
  }

  @override
  void markNeedsPaint() {
    if (info.currentStatus == _LayoutAndPaintStatus.idle && info.nextStatus == _LayoutAndPaintStatus.idle) {
      info.nextStatus = _LayoutAndPaintStatus.paint;
      addBuildInfoToManager();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _hadPainted = true;
    if (info.list == null || info.currentStatus == _LayoutAndPaintStatus.paint) {
      super.paint(context, offset);
    }
  }

  void addBuildInfoToManager() {
    if (info.list == null && buildManager != null) {
      if (_dependencyBuildInfo != null && _dependencyBuildInfo.list != null) {
        if (buildManager.reverse) {
          _dependencyBuildInfo.insertBefore(info);
        } else {
          _dependencyBuildInfo.insertAfter(info);
        }
      } else {
        buildManager._add(info);
      }
    }
  }
}

class DelayBuildManager {
  final LinkedList<_DelayAction> _list = LinkedList<_DelayAction>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  //是否后加入的事件先执行
  final bool reverse;

  //依赖于this的
  DelayBuildManager _dependent;
  //this依赖于的
  DelayBuildManager _dependentcy;

  DelayBuildManager({this.reverse = false});

  //this依赖于dependentcy
  void dependentOn(DelayBuildManager dependentcy) {
    if (dependentcy != null) {
      dependentcy._dependent = this;
      this._dependentcy = dependentcy;
    }
  }

  //删除依赖，this不再依赖其他DelayBuildManager
  void removeDependent() {
    _dependentcy?._dependent = null;
    this._dependentcy = null;
  }

  void _stop() {
    _isRunning = false;
    _dependent?._stop();
  }

  void _start() {
    if (!_isRunning) {
      _dependent?._stop();
      if (!canStart()) return;
      _isRunning = true;
      //用future，因为此时可能没有帧刷新了，所以此处不能用ServicesBinding.instance.addPostFrameCallback
      Future.delayed(
          Duration(
            milliseconds: 16,
          ), () {
        _actionNext();
      });
    }
  }

  //如果往上遍历_dependentcy有任务待执行，则该manager不能start
  bool canStart() {
    if (_dependentcy == null) return true;
    bool b = true;
    DelayBuildManager parentManager = _dependentcy;
    while (parentManager != null) {
      if (parentManager?._list?.isNotEmpty == true) {
        b = false;
        break;
      }
      parentManager = parentManager._dependentcy;
    }
    return b;
  }

  void _add(_DelayAction info) {
    _list.add(info);
    _start();
  }

  void _actionNext() {
    if (!_isRunning) return;
    if (_list.isNotEmpty) {
      _DelayAction info = reverse == true ? _list.last : _list.first;
      if (info is LayoutAndPaintAction) {
        if (info.nextStatus == _LayoutAndPaintStatus.idle || info.nextStatus == null) {
          info.currentStatus = _LayoutAndPaintStatus.idle;
          info.tryUnlink();
          _actionNext();
        } else {
          bool waitNextFrame = false;
          if (info.nextStatus == _LayoutAndPaintStatus.layout) {
            info.currentStatus = _LayoutAndPaintStatus.layout;
            info.nextStatus = _LayoutAndPaintStatus.paint;
            waitNextFrame = info.markNeedsLayout();
          } else if (info.nextStatus == _LayoutAndPaintStatus.paint) {
            info.currentStatus = _LayoutAndPaintStatus.paint;
            info.nextStatus = _LayoutAndPaintStatus.idle;
            waitNextFrame = info.markNeedsPaint();
          }
          if (waitNextFrame) {
            ServicesBinding.instance.addPostFrameCallback((_) {
              _actionNext();
            });
          } else {
            _actionNext();
          }
        }
      } else if (info is _BuildAction) {
        bool b = info.callback?.call();
        info.tryUnlink();
        if (b == true) {
          ServicesBinding.instance.addPostFrameCallback((_) {
            _actionNext();
          });
        } else {
          _actionNext();
        }
      } else {
        _actionNext();
      }
    } else {
      _isRunning = false;
      _dependent?._start();
    }
  }
}

class _DelayAction extends LinkedListEntry<_DelayAction> {
  void tryUnlink() {
    if (list != null) unlink();
  }
}

class _BuildAction extends _DelayAction {
  final VoidCallback callback;

  _BuildAction({
    @required this.callback,
  });
}

class LayoutAndPaintAction extends _DelayAction {
  _LayoutAndPaintStatus nextStatus;
  _LayoutAndPaintStatus currentStatus;
  final VoidCallback markNeedsLayout;
  final VoidCallback markNeedsPaint;

  LayoutAndPaintAction({
    @required this.markNeedsLayout,
    @required this.markNeedsPaint,
    this.currentStatus = _LayoutAndPaintStatus.idle,
    this.nextStatus = _LayoutAndPaintStatus.idle,
  }) : assert(markNeedsLayout != null, markNeedsPaint != null);
}
