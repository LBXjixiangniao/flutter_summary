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
  double height = 190;
  bool showWidth = true;
  ClipLocation location = ClipLocation.End;

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
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 120),
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
                  radius--;
                });
              },
              child: Text('cornerRadius delete'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  height ??= 190;
                  height++;
                });
              },
              child: Text('height add'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  height ??= 190;
                  height--;
                });
              },
              child: Text('height delete'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  height = null;
                });
              },
              child: Text('height null'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  showWidth = !showWidth;
                });
              },
              child: Text(showWidth ? 'hide width' : 'show width'),
            ),
            FlatButton(
              onPressed: () {
                setState(() {
                  if (location == ClipLocation.End) {
                    location = ClipLocation.Start;
                  } else {
                    location = ClipLocation.End;
                  }
                });
              },
              child: Text('$location'),
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
                  cornerColor: color,
                  showWidth: showWidth ? constraints.maxWidth : null,
                  showHeight: height,
                  clipLocation: location,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class Key {
  final int valueOne;
  final int valueTwo;
  Key(this.valueOne, this.valueTwo);

  bool operator ==(Object other) {
    return other is Key && other.valueTwo == valueTwo ;
  }

  @override
  int get hashCode => valueOne;
}
