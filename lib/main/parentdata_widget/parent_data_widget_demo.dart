import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_summary/widgets/default_app_bar.dart';

class ParentDataWidgetDemo extends StatefulWidget {
  @override
  _ParentDataWidgetDemoState createState() => _ParentDataWidgetDemoState();
}

class _ParentDataWidgetDemoState extends State<ParentDataWidgetDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(),
      body: Container(
        alignment: Alignment.center,
        color: Colors.yellow,
        child: FrogJar(
          child: FrogSize(
            size: Size(20, 20),
            child: Text('hello'),
          ),
          decoration: BoxDecoration(color: Colors.red),
        ),
      ),
    );
  }
}

class FrogJar extends DecoratedBox {
  const FrogJar({
    Key key,
    @required Decoration decoration,
    Widget child,
  })  : assert(decoration != null),
        super(key: key, child: child, decoration: decoration);
  @override
  RenderDecoratedBox createRenderObject(BuildContext context) {
    return RenderFrogJar(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }
}

class RenderFrogJar extends RenderDecoratedBox {
  RenderFrogJar({
    @required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
    RenderBox child,
  })  : assert(decoration != null),
        assert(position != null),
        assert(configuration != null),
        super(
          decoration: decoration,
          position: position,
          configuration: configuration,
        );
  @override
  void setupParentData(RenderObject child) {
    ///child是Text的RenderObject
    FrogJarParentData frogJarParentData = FrogJarParentData();
    frogJarParentData.size = Size(20, 20);
    child.parentData = frogJarParentData;
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
  }
}

class FrogJarParentData extends ParentData {
  Size size;
}

class FrogSize extends ParentDataWidget<FrogJarParentData> {
  FrogSize({
    Key key,
    @required this.size,
    @required Widget child,
  })  : assert(child != null),
        assert(size != null),
        super(key: key, child: child);

  final Size size;

  @override
  void applyParentData(RenderObject renderObject) {
    ///Text 的 renderobject
    final FrogJarParentData parentData = renderObject.parentData;
    if (parentData.size != size) {
      parentData.size = size;
      final RenderFrogJar targetParent = renderObject.parent;
      targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => throw UnimplementedError();
}
