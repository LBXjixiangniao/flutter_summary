import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/*
拷贝SliverGridDelegateWithFixedCrossAxisCount作修改，以minCrossAxisExtent为参考计算Item的Extent，但是计算出的Extent不能大于maxCrossAxisExtent
*/
class SliverGridDelegateWithSpecifiedMinExtentAndCrossAxisCount
    extends SliverGridDelegate {
  /// All of the arguments must not be null. The [maxCrossAxisExtent] and
  /// [mainAxisSpacing], and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  const SliverGridDelegateWithSpecifiedMinExtentAndCrossAxisCount({
    @required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.minCrossAxisExtent,
    this.minMainAxisExtent,
  })  : assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(childAspectRatio != null && childAspectRatio > 0);

  ///在满足这两个个条件前提下使用其他条件布局
  final double minCrossAxisExtent;
  final double minMainAxisExtent;

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  bool _debugAssertIsValid() {
    assert(crossAxisCount >= 0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());
    final double usableCrossAxisExtent =
        constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);
    double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;

    int crossCount = crossAxisCount;
    if (minCrossAxisExtent != null &&
        childCrossAxisExtent < minCrossAxisExtent) {
      childCrossAxisExtent = minCrossAxisExtent;
      crossCount = (constraints.crossAxisExtent + crossAxisSpacing) ~/
          childCrossAxisExtent;
    }
    double childMainAxisExtent = childCrossAxisExtent / childAspectRatio;
    if (minMainAxisExtent != null && childMainAxisExtent < minMainAxisExtent) {
      childMainAxisExtent = minMainAxisExtent;
    }
    return SliverGridRegularTileLayout(
      crossAxisCount: crossCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(
      SliverGridDelegateWithSpecifiedMinExtentAndCrossAxisCount oldDelegate) {
    return oldDelegate.minCrossAxisExtent != minCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio;
  }
}

//指定宽高的delegate
class SliverGridDelegateWithSpecificExtent extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// All of the arguments must not be null. The [maxCrossAxisExtent] and
  /// [mainAxisSpacing], and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  const SliverGridDelegateWithSpecificExtent({
    @required this.mainAxisExtent,
    @required this.crossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  })  : assert(mainAxisExtent != null && crossAxisExtent >= 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

//主轴大小
  final double mainAxisExtent;
  //纵轴大小
  final double crossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  bool _debugAssertIsValid() {
    assert(mainAxisExtent > 0.0 && crossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    return true;
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    assert(_debugAssertIsValid());

    final int crossAxisCount =
        (constraints.crossAxisExtent / (crossAxisExtent + crossAxisSpacing))
            .floor();
    return SliverGridCrossExtraOffsetLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: mainAxisExtent + mainAxisSpacing,
      crossAxisStride: crossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: mainAxisExtent,
      childCrossAxisExtent: crossAxisExtent,
      crossExtraOffset: crossAxisSpacing / 2,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithSpecificExtent oldDelegate) {
    return oldDelegate.mainAxisExtent != mainAxisExtent ||
        oldDelegate.crossAxisExtent != mainAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class SliverGridCrossExtraOffsetLayout extends SliverGridRegularTileLayout {
  final double crossExtraOffset;

  SliverGridCrossExtraOffsetLayout({
    @required int crossAxisCount,
    @required double mainAxisStride,
    @required double crossAxisStride,
    @required double childMainAxisExtent,
    @required double childCrossAxisExtent,
    @required bool reverseCrossAxis,
    @required this.crossExtraOffset,
  })  : assert(crossExtraOffset > 0),
        super(
          crossAxisCount: crossAxisCount,
          mainAxisStride: mainAxisStride,
          crossAxisStride: crossAxisStride,
          childMainAxisExtent: childMainAxisExtent,
          childCrossAxisExtent: childCrossAxisExtent,
          reverseCrossAxis: reverseCrossAxis,
        );

  double _getOffsetFromStartInCrossAxis(double crossAxisStart) {
    if (reverseCrossAxis)
      return crossAxisCount * crossAxisStride -
          crossAxisStart -
          childCrossAxisExtent -
          (crossAxisStride - childCrossAxisExtent);
    return crossAxisStart;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final double crossAxisStart =
        (index % crossAxisCount) * crossAxisStride + crossExtraOffset;
    return SliverGridGeometry(
      scrollOffset: (index ~/ crossAxisCount) * mainAxisStride,
      crossAxisOffset: _getOffsetFromStartInCrossAxis(crossAxisStart),
      mainAxisExtent: childMainAxisExtent,
      crossAxisExtent: childCrossAxisExtent,
    );
  }
}
