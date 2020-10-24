import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/single_child_widget.dart';

class HitTestManager extends StatefulWidget {
  @override
  _HitTestManagerState createState() => _HitTestManagerState();
}

class _HitTestManagerState extends State<HitTestManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HitTestManagerWidget(
            ignoreHitTest: true,
            ignoreWidgetBuilder: (child) => GestureDetector(
              onTap: () {
                print('tap one');
              },
              child: Container(
                color: Colors.yellow,
                width: 300,
                height: 200,
                alignment: Alignment.center,
                child: child,
              ),
            ),
            hitestChild: GestureDetector(
              onTap: () {
                print('tap two');
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class HitTestManagerWidget extends SingleChildRenderObjectWidget {
  final bool ignoreHitTest;
  final Widget Function(Widget child) ignoreWidgetBuilder;

  Widget hitTestWidget;
  RenderProxyBox hitTestRenderObject;
  HitTestManagerWidget({Key key, Widget hitestChild, this.ignoreWidgetBuilder, this.ignoreHitTest = true})
      : super(key: key) {
    if (ignoreHitTest == true) {
      hitTestRenderObject = RenderProxyBox();
      hitTestWidget = WidgetWithRenderObject(
        child: hitestChild,
        renderObject: hitTestRenderObject,
      );
    } else {
      hitTestWidget = hitestChild;
    }
  }

  @override
  Widget get child => ignoreWidgetBuilder?.call(hitTestWidget) ?? hitTestWidget;
  @override
  HitTestManagerRenderObject createRenderObject(BuildContext context) {
    return HitTestManagerRenderObject(hitTestRenderObject);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    // return renderObject;
  }
}

class HitTestManagerRenderObject extends RenderProxyBox {
  final RenderProxyBox hitTestRenderObject;

  HitTestManagerRenderObject(this.hitTestRenderObject);

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if (hitTestRenderObject != null) {
      hitTestRenderObject.hitTest(result, position: position);
      return false;
    }
    return super.hitTest(result, position: position);
  }
}

class WidgetWithRenderObject extends SingleChildRenderObjectWidget {
  final RenderProxyBox renderObject;
  WidgetWithRenderObject({
    Key key,
    Widget child,
    this.renderObject,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return renderObject;
  }
}
