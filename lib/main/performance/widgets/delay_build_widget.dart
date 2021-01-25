import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_summary/styles/color_helper.dart';
import 'package:flutter_summary/util/image_helper.dart';
import 'not_delay_build_widget.dart';
import 'round_corners_image_provider.dart';

class DelayBuildWidgetTestPage extends NotDelayBuildWidget {
  @override
  _DelayBuildWidgetTestPageState createState() => _DelayBuildWidgetTestPageState();
}

class _DelayBuildWidgetTestPageState extends NotDelayBuildWidgetState {
  @override
  String get pageTitle => '延时构建小部件测试';
  DelayBuildManager manager;
  DelayBuildManager managerTwo;
  DelayBuildManager managerThree;
  @override
  void initState() {
    super.initState();
    manager = DelayBuildManager(reverse: true);
    managerTwo = DelayBuildManager(reverse: true);
    managerThree = DelayBuildManager(reverse: true);
    managerTwo.dependentOn(manager);
    managerThree.dependentOn(managerTwo);
  }

  @override
  Widget item(GridInfo info, {bool useRoundCornerImageProvider = false}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: DelayBuildChild(
        buildManager: manager,
        width: itemWidth,
        height: itemHeight,
        addRepaintBoundary: false,
        child: Column(
          children: [
            Expanded(
              child: DelayBuildChild(
                height: itemHeight - 30,
                width: itemWidth,
                buildManager: managerTwo,
                addRepaintBoundary: false,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DelayBuildChild(
                            height: 60,
                            width: 60,
                            buildManager: managerThree,
                            // child: ClipRRect(
                            //   borderRadius: BorderRadius.circular(8),
                            //   child: Image.network(
                            //     info.url,
                            //     fit: BoxFit.cover,
                            //     width: 60,
                            //     height: 60,
                            //     cacheWidth: 120,
                            //     cacheHeight: 120,
                            //   ),
                            // ),
                            child: Image(
                              image: RoundCornersNetworkImage(
                                info.url,
                                cornerRadius: 8,
                                cornerColor: Colors.white,
                                imageShowSize: Size(60, 60),
                                cacheImageWidth: 120,
                                cacheImageHeight: 120,
                              ),
                              fit: BoxFit.cover,
                              width: itemWidth,
                              height: itemHeight - 30,
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(color: ColorHelper.DividerColor, spreadRadius: 1, blurRadius: 4)
                                  ],
                                ),
                                child: Text(
                                  info.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ColorHelper.Black153,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.red,
                                  ),
                                ),
                                child: Image.asset(
                                  ImageHelper.image(
                                    'icon_a_${info.aboveIcon}.png',
                                  ),
                                  width: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.yellow.withOpacity(0.5),
                              child: Text(
                                info.index.toString(),
                              ),
                            ),
                            Image.asset(
                              ImageHelper.image(
                                'icon_a_${info.aboveIcon}.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                info.title,
                                style: TextStyle(fontSize: 12, color: Colors.green),
                              ),
                              Text(
                                info.title,
                                style: TextStyle(fontSize: 12, color: Colors.purple),
                              ),
                            ],
                          ),
                          Text(
                            info.subTitle,
                            style: TextStyle(fontSize: 14, color: Colors.black12),
                          ),
                        ],
                      ),
                      Text(
                        info.subTitle + info.title,
                        style: TextStyle(fontSize: 12, color: Colors.red[100]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.red,
                          ),
                        ),
                        child: Text(
                          info.subTitle + info.subTitle,
                          style: TextStyle(fontSize: 13, color: Colors.blue[100]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Text(
                    info.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Image.asset(
                    ImageHelper.image('icon_${info.icon}.png'),
                    width: 25,
                  ),
                  Spacer(),
                  Text(
                    info.subTitle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BuildStatus {
  idle,
  layout,
  paint,
}

class DelayBuildChild extends SingleChildRenderObjectWidget {
  //用于控制DelayBuildChild的layout和paint
  final DelayBuildManager buildManager;
  //必须设置宽高，因为layout延迟了，为了不影响其他小部件layout，所以要设置固定的宽高
  final double width;
  final double height;
  //DelayBuildChild对应的RenderObject是否是repaintBoundary
  final bool addRepaintBoundary;
  DelayBuildChild({
    Key key,
    Widget child,
    this.buildManager,
    @required this.width,
    @required this.height,
    this.addRepaintBoundary = true,
  })  : assert(width != null && height != null),
        super(
          key: key,
          child: _BuildDelayMarker(
            child: child,
          ),
        );
  static DelayBuildChild defaultManager({
    Key key,
    Widget child,
    double width,
    double height,
    int index,
    bool addRepaintBoundary = true,
  }) {
    return DelayBuildChild(
      key: key,
      buildManager: defaultDelayBuildManager,
      child: child,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
    );
  }

  @override
  _BuildDelayElement createElement() {
    return _BuildDelayElement(this);
  }

  @override
  _BuildDelayRenderObject createRenderObject(BuildContext context) {
    _BuildDelayRenderObject renderObject = _BuildDelayRenderObject(
      buildManager: buildManager,
      width: width,
      height: height,
      addRepaintBoundary: addRepaintBoundary,
    );
    if (buildManager == null) {
      //往上寻找_BuildDelayMarkerElement并获取DelayBuildManager
      _BuildDelayMarkerElement marker = _BuildDelayMarker.of(context);
      assert(marker?._buildManager != null, '如果widget的buildManager为null，则marker._buildManager不能为空');
      renderObject.buildManager = marker?._buildManager;
      renderObject._dependencyBuildInfo = marker?._info;
    }
    return renderObject;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _BuildDelayRenderObject renderObject) {
    //buildManager在element中更新
    // renderObject.buildManager = buildManager;

    renderObject.width = width;
    renderObject.height = height;
    renderObject.addRepaintBoundary = addRepaintBoundary;
  }

  @override
  void didUnmountRenderObject(covariant _BuildDelayRenderObject renderObject) {
    renderObject.info.tryUnlink();
    super.didUnmountRenderObject(renderObject);
  }
}

class _BuildDelayElement extends SingleChildRenderObjectElement {
  _BuildDelayMarkerElement _marker;
  _BuildDelayElement(SingleChildRenderObjectWidget widget) : super(widget);
  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    _BuildDelayMarker.of(this, listen: true);
  }

  @override
  _BuildDelayRenderObject get renderObject => super.renderObject;

  @override
  DelayBuildChild get widget => super.widget;

  @override
  void update(covariant DelayBuildChild newWidget) {
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
    _BuildDelayMarkerElement marker = _BuildDelayMarker.of(this);
    assert(marker != null, '如果widget的buildManager为null，则marker不能为空');
    renderObject.buildManager = marker?._buildManager;

    renderObject._dependencyBuildInfo = marker?._info;
    _marker?.buildManager = marker?._buildManager;
  }
}

///用来传递DelayBuildChild的buildManager和其renderObject的BuildInfo到子树
class _BuildDelayMarker extends InheritedWidget {
  _BuildDelayMarker({
    Key key,
    Widget child,
  }) : super(key: key, child: child);
  @override
  @override
  _BuildDelayMarkerElement createElement() {
    return _BuildDelayMarkerElement(this);
  }

  static _BuildDelayMarkerElement of(BuildContext context, {bool listen}) {
    InheritedElement element = context.getElementForInheritedWidgetOfExactType<_BuildDelayMarker>();
    if (listen == true && element != null) {
      context.dependOnInheritedElement(element);
    }
    return element as _BuildDelayMarkerElement;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}

//用来传递_BuildDelayRenderObject的info和buildManager到子树
class _BuildDelayMarkerElement extends InheritedElement {
  LayoutAndPaintAction _info;
  DelayBuildManager _buildManager;
  _BuildDelayMarkerElement(InheritedWidget widget) : super(widget);

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
    if (parent is _BuildDelayElement) {
      _BuildDelayRenderObject parentRenderObject = parent.renderObject;
      _info = parentRenderObject.info;
      _buildManager = parentRenderObject.buildManager;
      parent._marker = this;
    }

    super.mount(parent, newSlot);
  }
}

class _BuildDelayRenderObject extends RenderProxyBox {
  //info依赖于_dependencyBuildInfo
  LayoutAndPaintAction _dependencyBuildInfo;

  LayoutAndPaintAction info;
  DelayBuildManager buildManager;
  double width;
  double height;
  bool addRepaintBoundary;
  //标识是否已经paint过了，因为如果还没paint过，则_needsPaint为true，这时候调用markNeedsPaint会被忽略
  bool _hadPainted = false;
  _BuildDelayRenderObject({
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
    if (info.currentStatus != _BuildStatus.layout) {
      info.nextStatus = _BuildStatus.layout;
      addBuildInfoToManager();
    }
  }

  @override
  void performLayout() {
    if (info.currentStatus == _BuildStatus.layout) {
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
    if (info.currentStatus == _BuildStatus.idle && info.nextStatus == _BuildStatus.idle) {
      info.nextStatus = _BuildStatus.paint;
      addBuildInfoToManager();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _hadPainted = true;
    if (info.list == null || info.currentStatus == _BuildStatus.paint) {
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

final DelayBuildManager defaultDelayBuildManager = DelayBuildManager(reverse: true);

class DelayBuildManager {
  final LinkedList<DelayAction> _list = LinkedList<DelayAction>();
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  //是否后加入的事件先执行
  final bool reverse;

  //依赖于this的
  DelayBuildManager _dependent;
  //this依赖于的
  DelayBuildManager _dependentcy;

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

  DelayBuildManager({this.reverse = false});
  void _add(DelayAction info) {
    _list.add(info);
    _start();
  }

  void _actionNext() {
    if (!_isRunning) return;
    if (_list.isNotEmpty) {
      DelayAction info = reverse == true ? _list.last : _list.first;
      if (info is LayoutAndPaintAction) {
        if (info.nextStatus == _BuildStatus.idle || info.nextStatus == null) {
          info.currentStatus = _BuildStatus.idle;
          info.tryUnlink();
          _actionNext();
        } else {
          bool waitNextFrame = false;
          if (info.nextStatus == _BuildStatus.layout) {
            info.currentStatus = _BuildStatus.layout;
            info.nextStatus = _BuildStatus.paint;
            waitNextFrame = info.markNeedsLayout();
          } else if (info.nextStatus == _BuildStatus.paint) {
            info.currentStatus = _BuildStatus.paint;
            info.nextStatus = _BuildStatus.idle;
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
      } else if (info is MountAction) {
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

class DelayAction extends LinkedListEntry<DelayAction> {
  void tryUnlink() {
    if (list != null) unlink();
  }
}

class MountAction extends DelayAction {
  final VoidCallback callback;

  MountAction({
    @required this.callback,
  });
}

class LayoutAndPaintAction extends DelayAction {
  _BuildStatus nextStatus;
  _BuildStatus currentStatus;
  final VoidCallback markNeedsLayout;
  final VoidCallback markNeedsPaint;

  LayoutAndPaintAction({
    @required this.markNeedsLayout,
    @required this.markNeedsPaint,
    this.currentStatus = _BuildStatus.idle,
    this.nextStatus = _BuildStatus.idle,
  }) : assert(markNeedsLayout != null, markNeedsPaint != null);
}
