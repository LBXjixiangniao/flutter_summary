import 'package:flutter_summary/main/performance/manager.dart/manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/util/image_helper.dart';
import 'package:round_corners_image_provider/round_corners_image_provider.dart';

class NotRoundedImagePage extends StatefulWidget {
  @override
  _RoundedImagePageState createState() => _RoundedImagePageState();
}

class _RoundedImagePageState extends State<NotRoundedImagePage> {
  int radius = 30;
  Color color = Colors.red;
  double height = 190;
  bool showWidth = true;
  ClipLocation location = ClipLocation.End;
  DelayBuildManager manager;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget wrapWidget(bool roundCorner) {
    return Wrap(
      children: [
        for (var i = 0; i < 60; i++)
          roundCorner
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(radius.toDouble()),
                  child: Image.asset(
                    ImageHelper.image('icon_round_corners.png'),
                    width: 60,
                    height: 60,
                  ),
                )
              : Image.asset(
                  ImageHelper.image('icon_round_corners.png'),
                  width: 60,
                  height: 60,
                ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: Text('圆角图片测试'),
        actions: [
          FlatButton(
            onPressed: () {
              setState(() {
              });
            },
            child: Text('刷新'),
          ),
        ],
      ),
      body: wrapWidget(false),
    );
  }
}
