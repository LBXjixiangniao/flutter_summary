import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore: must_be_immutable
class HitTestManagerWidget extends SingleChildRenderObjectWidget {
  final bool ignoreHitTest;
  final Widget Function(Widget child) ignoreWidgetBuilder;

  Widget hitTestWidget;
  HitTestManagerWidget({Key key, Widget hitestChild, this.ignoreWidgetBuilder, this.ignoreHitTest = true}) : super(key: key) {
    hitTestWidget = WidgetWithRenderObject(
      child: hitestChild,
    );
  }

  @override
  Widget get child => ignoreWidgetBuilder?.call(hitTestWidget) ?? hitTestWidget;
  @override
  HitTestManagerRenderObject createRenderObject(BuildContext context) {
    return HitTestManagerRenderObject()..ignoreHitTest = ignoreHitTest;
  }

  @override
  void updateRenderObject(BuildContext context, covariant HitTestManagerRenderObject renderObject) {
    renderObject.ignoreHitTest = ignoreHitTest;
  }
}

class HitTestManagerRenderObject extends RenderProxyBox {
  bool ignoreHitTest = false;
  Offset paintOffset;

  HitTestManagerRenderObject();

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if (ignoreHitTest && size.contains(position)) {
      HitTestRenderObject hitTestRenderObject;

      void visit(RenderObject renderObject) {
        assert(hitTestRenderObject == null); // this verifies that there's only one child
        if (renderObject is HitTestRenderObject)
          hitTestRenderObject = renderObject;
        else
          renderObject.visitChildren(visit);
      }

      visit(child);

      if (hitTestRenderObject != null) {
        hitTestRenderObject.hitTest(result, position: position - (hitTestRenderObject.paintOffset - paintOffset));
        return false;
      }
    }
    return super.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    paintOffset = offset;
    super.paint(context, offset);
  }
}

class WidgetWithRenderObject extends SingleChildRenderObjectWidget {
  WidgetWithRenderObject({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  HitTestRenderObject createRenderObject(BuildContext context) {
    return HitTestRenderObject();
  }
}

class HitTestRenderObject extends RenderProxyBox {
  Offset paintOffset;
  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    return super.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    paintOffset = offset;
    super.paint(context, offset);
  }
}