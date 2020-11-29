import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/**
 * 控制是否允许child接受点击事件，
 * 如果checkHitTestPermission返回true则允许接受点击事件，
 * 否则child不接受点击事件
 */
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
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    if(checkHitTestPermission != null && checkHitTestPermission(position) == false)  return false;
    return super.hitTest(result, position: position);
  }
}

/**
 * 控制是否拦截点击事件，如果checkHitTestAbsorb返回true则拦截点击事件，
 * 效果和AbsorbPointer类似。
 * 无论checkHitTestAbsorb返回什么，都不影响child接受点击事件
 */
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
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    bool b = super.hitTest(result, position: position);
    return b || checkHitTestAbsorb?.call(position) == true;
  }
}

/**
 * 控制是否忽略ignoreWidgetBuilder中创建的widget的点击事件
 * 如果ignoreHitTest为true，则ignoreWidgetBuilder中穿件的widget不接受点击事件，
 * 但是ignoreWidgetBuilder中的参数child（则hitTestWidget）还是正常接受点击事件。
 * 如果ignoreHitTest不为true，则hitTest按正常逻辑传递。
 */
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