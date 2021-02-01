import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomLayoutPage extends StatefulWidget {
  @override
  _CustomLayoutPageState createState() => _CustomLayoutPageState();
}

class _CustomLayoutPageState extends State<CustomLayoutPage> {
  TextEditingController editingController = TextEditingController();
  StreamController streamController = StreamController();

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自定义layout'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: TextField(
                controller: editingController,
                onChanged: (value) {
                  streamController.add(0);
                },
              ),
            ),
            SizedBox(height: 30),
            StreamBuilder(
              stream: streamController.stream,
              builder: (_, __) {
                return CustomRow(
                  children: <Widget>[
                    WithIDRenderObjectWidget(
                      uid: 'line',
                      child: VerticalDivider(
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: WithIDRenderObjectWidget(
                        uid: 'text',
                        child: Text(editingController.text),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRow extends Row {
  CustomRow({
    Key key,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline = TextBaseline.alphabetic,
    List<Widget> children = const <Widget>[],
  }) : super(
          children: children,
          key: key,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
        );

  @override
  RenderFlex createRenderObject(BuildContext context) {
    return CustomRenderFlex(
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: getEffectiveTextDirection(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
    );
  }
}

class CustomRenderFlex extends RenderFlex {
  CustomRenderFlex({
    Axis direction = Axis.horizontal,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline textBaseline,
    Clip clipBehavior = Clip.none,
  }) : super(
          direction: direction,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          textBaseline: textBaseline,
          clipBehavior: clipBehavior,
        );

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    assert(constraints != null);

    WithIDRenderObject lineChild;
    WithIDRenderObject textChild;
    RenderBox child = firstChild;
    while (child != null) {
      if (child is WithIDRenderObject) {
        if (child.uid == 'line') {
          lineChild = child;
        } else if (child.uid == 'text') {
          textChild = child;
        }
      }
      final FlexParentData childParentData = child.parentData as FlexParentData;
      child = childParentData.nextSibling;
    }

    ///layout
    textChild.layout(BoxConstraints(maxWidth: constraints.maxWidth - 28), parentUsesSize: true);
    lineChild.layout(BoxConstraints(minWidth: 0, maxWidth: 28, maxHeight: textChild.size.height), parentUsesSize: true);

    ///设置this的size
    size = Size(constraints.maxWidth, textChild.size.height);

    ///设置child.parentData.offset
    final FlexParentData leftChildParentData = lineChild.parentData as FlexParentData;
    leftChildParentData.offset = Offset(0, 0);
    final FlexParentData rightChildParentData = textChild.parentData as FlexParentData;
    rightChildParentData.offset = Offset(lineChild.size.width, 0);
  }
}

class WithIDRenderObjectWidget extends SingleChildRenderObjectWidget {
  final String uid;
  const WithIDRenderObjectWidget({Key key, Widget child, this.uid}) : super(key: key, child: child);

  @override
  WithIDRenderObject createRenderObject(BuildContext context) {
    return WithIDRenderObject(uid: uid);
  }

  @override
  void updateRenderObject(BuildContext context, covariant WithIDRenderObject renderObject) {
    renderObject.uid = uid;
  }
}

class WithIDRenderObject extends RenderProxyBox {
  String uid;
  WithIDRenderObject({this.uid, RenderBox child}) : super(child);
}
