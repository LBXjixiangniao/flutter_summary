import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_summary/main/performance/manager.dart/manager.dart';
import 'package:flutter_summary/main/performance/widgets/round_corners_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/util/image_helper.dart';

import 'delay_build_widget.dart';
import 'isolate_manager.dart';

class RoundedImagePage extends StatefulWidget {
  @override
  _RoundedImagePageState createState() => _RoundedImagePageState();
}

class _RoundedImagePageState extends State<RoundedImagePage> {
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
    manager = DelayBuildManager();
  }

  @override
  Widget build(BuildContext context) {
    print('========\n');
    print('radius:$radius');
    print('color:$color');
    print('height:$height');
    print('showWidth:$showWidth');
    print('location:$location \n');
    print('*************\n');

    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        title: Text('圆角图片测试'),
        actions: [
          FlatButton(
            onPressed: () {
              setState(() {
                // PaintingBinding.instance.imageCache.clear();
              });
            },
            child: Text('刷新'),
          ),
        ],
      ),
      body: Wrap(
        children: [
          for (var i = 0; i < 30; i++)
            // Image(
            //   image: RoundCornersAssetImage(
            //     ImageHelper.image('icon_round_corners.png'),
            //     // 'https://images.pexels.com/photos/6032603/pexels-photo-6032603.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
            //     cornerRadius: radius,
            //     cornerColor: color,
            //     imageShowSize: Size(60, 60),
            //   ),
            //   width: 60,
            //   height: 60,
            // ),
          ClipRRect(
            borderRadius: BorderRadius.circular(radius.toDouble()),
            child: Image.asset(
              ImageHelper.image('icon_round_corners.png'),
              width: 60,
              height: 60,
            ),
          )
        ],
      ),
    );
  }
}

class Key {
  final int valueOne;
  final int valueTwo;
  Key(this.valueOne, this.valueTwo);

  bool operator ==(Object other) {
    return other is Key && other.valueTwo == valueTwo;
  }

  @override
  int get hashCode => valueOne;
}
