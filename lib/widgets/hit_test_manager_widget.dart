import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore: must_be_immutable
class HitTestCheckWidget extends SingleChildRenderObjectWidget {
  final bool Function(Offset) checkHitTestPermission;
  HitTestCheckWidget({Key key, Widget child, this.checkHitTestPermission}) : super(key: key,child: child);

  @override
  _HitTestCheckRenderObject createRenderObject(BuildContext context) {
    return _HitTestCheckRenderObject()..checkHitTestPermission = checkHitTestPermission;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _HitTestCheckRenderObject renderObject) {
    renderObject.checkHitTestPermission = checkHitTestPermission;
  }
}

class _HitTestCheckRenderObject extends RenderProxyBox {
  bool Function(Offset) checkHitTestPermission;

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    print('_HitTestCheckRenderObject$event');
    super.handleEvent(event, entry);
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if(checkHitTestPermission != null && checkHitTestPermission(position) == false)  return false;
    return super.hitTest(result, position: position);
  }
}

class HitTestAbsorbCheckWidget extends SingleChildRenderObjectWidget {
  final bool Function(Offset) checkHitTestAbsorb;
  HitTestAbsorbCheckWidget({Key key, Widget child, this.checkHitTestAbsorb}) : super(key: key,child: child);

  @override
  _HitTestAbsorbCheckRenderObject createRenderObject(BuildContext context) {
    return _HitTestAbsorbCheckRenderObject()..checkHitTestAbsorb = checkHitTestAbsorb;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _HitTestAbsorbCheckRenderObject renderObject) {
    renderObject.checkHitTestAbsorb = checkHitTestAbsorb;
  }
}

class _HitTestAbsorbCheckRenderObject extends RenderProxyBox {
  bool Function(Offset) checkHitTestAbsorb;

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    print('_HitTestAbsorbCheckRenderObject$event');
    super.handleEvent(event, entry);
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    bool b = super.hitTest(result, position: position);
    return b || checkHitTestAbsorb?.call(position) == true;
  }
}

// ignore: must_be_immutable
class HitTestIgnoreManagerWidget extends SingleChildRenderObjectWidget {
  final bool ignoreHitTest;
  final Widget Function(Widget child) ignoreWidgetBuilder;

  Widget hitTestWidget;
  HitTestIgnoreManagerWidget({Key key, Widget hitestChild, this.ignoreWidgetBuilder, this.ignoreHitTest = true}) : super(key: key) {
    hitTestWidget = _WidgetWithRenderObject(
      child: hitestChild,
    );
  }

  @override
  Widget get child => ignoreWidgetBuilder?.call(hitTestWidget) ?? hitTestWidget;
  @override
  _HitTestManagerRenderObject createRenderObject(BuildContext context) {
    return _HitTestManagerRenderObject()..ignoreHitTest = ignoreHitTest;
  }

  @override
  void updateRenderObject(BuildContext context, covariant _HitTestManagerRenderObject renderObject) {
    renderObject.ignoreHitTest = ignoreHitTest;
  }
}

class _HitTestManagerRenderObject extends RenderProxyBox {
  bool ignoreHitTest = false;
  Offset paintOffset;

  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if (ignoreHitTest && size.contains(position)) {
      _HitTestRenderObject hitTestRenderObject;

      void visit(RenderObject renderObject) {
        if(hitTestRenderObject != null) return;
        if (renderObject is _HitTestRenderObject)
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

class _WidgetWithRenderObject extends SingleChildRenderObjectWidget {
  _WidgetWithRenderObject({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  _HitTestRenderObject createRenderObject(BuildContext context) {
    return _HitTestRenderObject();
  }
}

class _HitTestRenderObject extends RenderProxyBox {
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