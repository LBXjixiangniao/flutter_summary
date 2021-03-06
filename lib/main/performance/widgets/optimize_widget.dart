import 'package:delay_widget/delay_widget.dart';
import 'package:flutter/material.dart';
import 'package:round_corners_image_provider/round_corners_image_provider.dart';
import 'common_widget.dart';

class OptimizePage extends CommonPage {
  @override
  _OptimizePageState createState() => _OptimizePageState();
}

class _OptimizePageState extends CommonPageState {
  @override
  String get pageTitle => '优化后的页面';
  DelayManager manager;
  DelayManager managerTwo;
  DelayManager managerThree;
  @override
  void initState() {
    super.initState();
    manager = DelayManager(reverse: true);
    managerTwo = DelayManager(reverse: true);
    managerThree = DelayManager(reverse: true);
    managerTwo.dependentOn(manager);
    managerThree.dependentOn(managerTwo);
  }

  @override
  Widget detailWidget(GridInfo info, double width, double height) {
    return DelayLayoutAndPaintWidget(
      height: height,
      width: width,
      delayManager: managerTwo,
      addRepaintBoundary: false,
      child: super.detailWidget(info, width, height),
    );
  }

  @override
  Widget networkImage(GridInfo info, double width, double height) {
    return DelayLayoutAndPaintWidget(
      height: height,
      width: width,
      delayManager: managerThree,
      child: Image(
        image: RoundCornerCachedNetworkImage(
          info.url,
          imageShowSize: Size(width, height),
          cornerRadius: 8,
          cornerColor: Colors.white,
        ),
      ),
      // super.networkImage(info, width, height),
    );
  }

  @override
  Widget item(GridInfo info) {
    return DelayBuildWidget(
      delayManager: manager,
      builder: (_) => super.item(info),
    );
  }
}
