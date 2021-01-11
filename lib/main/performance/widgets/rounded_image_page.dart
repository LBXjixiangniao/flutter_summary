import 'dart:math';
import 'dart:typed_data';
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
  }

  void getImage() async {
    // put them here
    ByteData byteData = (await rootBundle.load(ImageHelper.image('icon_round_corners.png')));
    img.Image imageInfo = img.decodeImage(byteData.buffer.asUint8List());
    createRoundCorners(image: imageInfo, radius: 180,);

    image = Image.memory(img.encodePng(imageInfo));

    setState(() {});
  }

  void createRoundCorners({
    @required img.Image image,
    @required int radius,
    Color color,
  }) {
    assert(radius > 1 && image != null);
    if (radius <= 1 || image == null) return;
    //AARRGGBB
    int colorValue = color?.value ?? Colors.transparent.value;
    // AABBGGRR
    colorValue = ((colorValue & 0x00ff0000) >> 16) | ((colorValue & 0xff) << 16) | (colorValue & 0xff00ff00);

    // 右下角中心点
    _Position rightBottomCenter = _Position(image.width - radius, image.height - radius);
    // 右上角中心点
    _Position rightTopCenter = _Position(image.width - radius, radius - 1);
    // 左上角中心点
    _Position leftTopCenter = _Position(radius - 1, radius - 1);
    // 左下角中心点
    _Position leftBottomCenter = _Position(radius - 1, image.height - radius);
    void traverseSetPixelsColor({int x, int startY}) {
      int y = max(startY, x);
      while (y < radius && y >= x && pow(x, 2) + pow(y, 2) < pow(radius, 2)) {
        y++;
      }

      for (int i = y; i < radius; i++) {
        int pixelX = x;
        int pixelY = i;

        ///右下角
        setPixelColor(
          image: image,
          center: rightBottomCenter,
          relativePoint: _Position(pixelX, pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          setPixelColor(
            image: image,
            center: rightBottomCenter,
            relativePoint: _Position(pixelY, pixelX),
            colorValue: colorValue,
          );

        ///右上角
        setPixelColor(
          image: image,
          center: rightTopCenter,
          relativePoint: _Position(pixelX, -pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          setPixelColor(
            image: image,
            center: rightTopCenter,
            relativePoint: _Position(pixelY, -pixelX),
            colorValue: colorValue,
          );

        ///左上角
        setPixelColor(
          image: image,
          center: leftTopCenter,
          relativePoint: _Position(-pixelX, -pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          setPixelColor(
            image: image,
            center: leftTopCenter,
            relativePoint: _Position(-pixelY, -pixelX),
            colorValue: colorValue,
          );

        ///左下角
        setPixelColor(
          image: image,
          center: leftBottomCenter,
          relativePoint: _Position(-pixelX, pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          setPixelColor(
            image: image,
            center: leftBottomCenter,
            relativePoint: _Position(-pixelY, pixelX),
            colorValue: colorValue,
          );
      }
      if (x < radius) {
        traverseSetPixelsColor(x: x + 1, startY: y - 1);
      }
    }

    traverseSetPixelsColor(
      x: 0,
      startY: radius,
    );
  }

  void setPixelColor({
    @required _Position center,
    @required _Position relativePoint,
    int colorValue,
    @required img.Image image,
  }) {
    int x = center.x + relativePoint.x;
    int y = center.y + relativePoint.y;
    image.setPixel(x, y, colorValue);
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
        padding: const EdgeInsets.all(8),
        child: image,
      ),
    );
  }
}

class _Position {
  final int x;
  final int y;

  _Position(this.x, this.y);
}
