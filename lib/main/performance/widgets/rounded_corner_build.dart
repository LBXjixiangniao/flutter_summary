import 'package:flutter/material.dart';

import 'not_delay_build_widget.dart';

class RoundedCornderBuildPage extends NotDelayBuildWidget {
  @override
  _RoundedCornderBuildPageState createState() => _RoundedCornderBuildPageState();
}

class _RoundedCornderBuildPageState extends NotDelayBuildWidgetState {
  @override
  String get pageTitle => '图片圆角小部件测试';

  @override
  Widget item(GridInfo info, {bool useRoundCornerImageProvider = false}) {
    return super.item(info,useRoundCornerImageProvider:true);
  }
}