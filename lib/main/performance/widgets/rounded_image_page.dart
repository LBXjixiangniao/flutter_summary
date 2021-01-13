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

  @override
  Widget build(BuildContext context) {
    int radiusOne = Random().nextInt(100) + 10;
    int radiusTwo = Random().nextInt(30) + 10;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // image ?? SizedBox(),
            // Image(
            //   image: RoundCornersAssetImage(
            //     ImageHelper.image('icon_round_corners.png'),
            //     cornerRadius: 30,
            //   ),
            // ),
            // Image.asset(ImageHelper.image('icon_round_corners.png'),),
            // Image.asset(ImageHelper.image('icon_round_corners.png'),),
            Image(
              image: RoundCornersAssetImage(
                ImageHelper.image('icon_round_corners.png'),
                cornerRadius: radiusOne,
              ),
            ),
            Image(
              image: RoundCornersAssetImage(
                ImageHelper.image('icon_round_corners.png'),
                cornerRadius: radiusTwo,
              ),
            )
          ],
        ),
      ),
    );
  }
}
