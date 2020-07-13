import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomViewportSliver extends SingleChildRenderObjectWidget {
  /// Creates a sliver that fills the remaining space in the viewport.
  const CustomViewportSliver({
    Key key,
    Widget child,
    this.heightBuilder,
  }) : super(key: key, child: child);
  final double Function(double viewportHeight,double precedingScrollExtent) heightBuilder;
  @override
  CustomViewportSliverViewport createRenderObject(BuildContext context) {
    return CustomViewportSliverViewport(heightBuilder: heightBuilder);
  }

  @override
  void updateRenderObject(
      BuildContext context, CustomViewportSliverViewport renderObject) {
        renderObject.heightBuilder = heightBuilder;
      }
}

class CustomViewportSliverViewport extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox] which is sized to fit
  /// the remaining space in the viewport.
  CustomViewportSliverViewport({
    RenderBox child,
    this.heightBuilder,
  }) : super(child: child);

  double Function(double viewportHeight,double precedingScrollExtent) heightBuilder;

  @override
  void performLayout() {
    double extent = heightBuilder != null ? heightBuilder(constraints.viewportMainAxisExtent,constraints.precedingScrollExtent) : 0;
    extent = math.max(extent, 0);
    child.layout(
      constraints.asBoxConstraints(
        minExtent: extent,
        maxExtent: extent,
      ),
      parentUsesSize: true,
    );

    assert(
      extent.isFinite,
      'The calculated extent for the child of SliverFillRemaining is not finite.'
      'This can happen if the child is a scrollable, in which case, the'
      'hasScrollBody property of SliverFillRemaining should not be set to'
      'false.',
    );
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: extent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: extent,
      paintExtent: paintedChildSize,
      maxPaintExtent: paintedChildSize,
      hasVisualOverflow: extent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    if (child != null) setChildParentData(child, constraints, geometry);
  }
}