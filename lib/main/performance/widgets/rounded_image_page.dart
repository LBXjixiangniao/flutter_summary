import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_summary/main/performance/widgets/round_corners_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/util/image_helper.dart';

import 'isolate_manager.dart';

class RoundedImagePage extends StatefulWidget {
  @override
  _RoundedImagePageState createState() => _RoundedImagePageState();
}

class _RoundedImagePageState extends State<RoundedImagePage> {
  int radius = 10;
  Color color = Colors.red;
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
                PaintingBinding.instance.imageCache.clear();
              });
            },
            child: Text('刷新'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: () {
                setState(() {
                  radius++;
                });
              },
              child: Text('cornerRadius add'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  Random random = Random();
                  color = Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 255);
                });
              },
              child: Text('change color'),
            ),
            LayoutBuilder(builder: (_, constraints) {
              return Image(
                image: RoundCornersAssetImage(
                  ImageHelper.image('icon_round_corners.png'),
                  cornerRadius: radius,
                  cornerColor: Colors.red,
                  showWidth: constraints.maxWidth,
                  showHeight: 190,
                  clipLocation: ClipLocation.End,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
