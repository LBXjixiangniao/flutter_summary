import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_summary/main/performance/widgets/round_corners_image.dart';
import 'package:flutter_summary/main/performance/widgets/round_corners_image_provider.dart';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_summary/util/image_helper.dart';

class RoundedImagePage extends StatefulWidget {
  @override
  _RoundedImagePageState createState() => _RoundedImagePageState();
}

class _RoundedImagePageState extends State<RoundedImagePage> {
  Image image;

  @override
  void initState() {
    super.initState();
    // assign it value here
    getImage();
    ReceivePort receivePort = ReceivePort();
    //创建新的isolate
    Isolate.spawn(entryPoint, receivePort.sendPort, debugName: 'gyIsolate');

    receivePort.listen((message) {
      debugPrint('receive $message');
    });
  }

  void getImage() async {
    // put them here
    // ByteData byteData = (await rootBundle.load(ImageHelper.image('icon_round_corners.png')));
    // img.Image imageInfo = img.decodeImage(byteData.buffer.asUint8List());
    // Uint32List uint32list = imageInfo.data.sublist(imageInfo.data.length ~/ 2);
    // imageInfo = img.Image.fromBytes(imageInfo.width, imageInfo.height~/3, uint32list);
    // imageInfo.createRoundCorners(image: imageInfo, radius: 400, color: Colors.red);
    // image = Image.memory(img.encodePng(imageInfo));

    // setState(() {});
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
                getImage();
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
                cornerRadius: 100,
              ),
            ),
            Image(
              image: RoundCornersAssetImage(
                ImageHelper.image('icon_round_corners.png'),
                cornerRadius: 100,
              ),
            )
          ],
        ),
      ),
    );
  }
}

void entryPoint(SendPort sendPort) {
  //该过程运行在新的isolate
  Timer.periodic(Duration(seconds: 5), (Timer timer) {
    sendPort.send("hello gityuan");
    debugPrint('build:${Isolate.current.debugName}');
  });
}
