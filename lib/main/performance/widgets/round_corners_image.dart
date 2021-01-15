import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as IMG;

extension IMg_Extension on IMG.Image {
  void setRoundCorners({
    @required int radius,
    Color color,
  }) {
    createRoundCorners(image: this, radius: radius, color: color);
  }

  static void createRoundCorners({
    @required IMG.Image image,
    @required int radius,
    Color color,
  }) {
    assert(radius > 1 && image != null);
    if (radius == null || radius <= 1 || image == null) return;
    Color toSetColor = color ?? Colors.transparent;
    int colorValue = IMG.Color.fromRgba(toSetColor.red, toSetColor.green, toSetColor.blue, toSetColor.alpha);

    // 右下角中心点
    _Position rightBottomCenter = _Position(image.width - radius, image.height - radius);
    // 右上角中心点
    _Position rightTopCenter = _Position(image.width - radius, radius - 1);
    // 左上角中心点
    _Position leftTopCenter = _Position(radius - 1, radius - 1);
    // 左下角中心点
    _Position leftBottomCenter = _Position(radius - 1, image.height - radius);

    //圆弧和正方形对角线相交点的x坐标
    double seperatedX = sqrt(radius * radius / 2);

    void traverseSetPixelsColor({int x, int startY}) {
      if (x >= seperatedX) {
        startY = x;
      } else {
        startY = max(startY, x);
        while (startY < radius && startY >= x && pow(x, 2) + pow(startY, 2) < pow(radius, 2)) {
          startY++;
        }
      }

      for (int i = startY; i < radius; i++) {
        int pixelX = x;
        int pixelY = i;

        ///右下角
        _setPixelColor(
          image: image,
          center: rightBottomCenter,
          relativePoint: _Position(pixelX, pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          _setPixelColor(
            image: image,
            center: rightBottomCenter,
            relativePoint: _Position(pixelY, pixelX),
            colorValue: colorValue,
          );

        ///右上角
        _setPixelColor(
          image: image,
          center: rightTopCenter,
          relativePoint: _Position(pixelX, -pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          _setPixelColor(
            image: image,
            center: rightTopCenter,
            relativePoint: _Position(pixelY, -pixelX),
            colorValue: colorValue,
          );

        ///左上角
        _setPixelColor(
          image: image,
          center: leftTopCenter,
          relativePoint: _Position(-pixelX, -pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          _setPixelColor(
            image: image,
            center: leftTopCenter,
            relativePoint: _Position(-pixelY, -pixelX),
            colorValue: colorValue,
          );

        ///左下角
        _setPixelColor(
          image: image,
          center: leftBottomCenter,
          relativePoint: _Position(-pixelX, pixelY),
          colorValue: colorValue,
        );
        if (pixelX != pixelY)
          _setPixelColor(
            image: image,
            center: leftBottomCenter,
            relativePoint: _Position(-pixelY, pixelX),
            colorValue: colorValue,
          );
      }
      if (x < radius) {
        traverseSetPixelsColor(x: x + 1, startY: startY - 1);
      }
    }

    traverseSetPixelsColor(
      x: 0,
      startY: radius,
    );
  }

  static void _setPixelColor({
    @required _Position center,
    @required _Position relativePoint,
    @required int colorValue,
    @required IMG.Image image,
  }) {
    int x = center.x + relativePoint.x;
    int y = center.y + relativePoint.y;
    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      image.setPixel(x, y, colorValue);
    }
  }
}

class _Position {
  final int x;
  final int y;

  _Position(this.x, this.y);
}
