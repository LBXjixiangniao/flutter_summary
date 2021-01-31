import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/src/image_provider/_image_provider_io.dart' if (dart.library.html) 'package:cached_network_image/src/image_provider/_image_provider_web.dart'
    as CachedNetworkImage;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter/src/painting/_network_image_io.dart' if (dart.library.html) 'package:flutter/src/painting/_network_image_web.dart' as network_image;

import 'isolate_manager.dart';

final IsolateManager _isolateManager = IsolateManager(
  isolateFunction: _createRoundCornerIsolateMethod,
  reverseOrder: true,
  maxCocurrentIsolateCount: 3,
);

const int MinRadius = 2;

enum ClipLocation {
  Start,
  Center,
  End,
}

class _Position {
  final int x;
  final int y;

  _Position(this.x, this.y);
}

extension _RadiusDouble on int {
  bool get isValideRadius => this != null && this >= MinRadius;
}

extension _Uint8ListExtension on Uint32List {
  Uint32List copyCrop(int width, int height, int x, int y, int w, int h) {
    // Make sure crop rectangle is within the range of the src image.
    x = x.clamp(0, width - 1).toInt();
    y = y.clamp(0, height - 1).toInt();
    if (x + w > width) {
      w = width - x;
    }
    if (y + h > height) {
      h = height - y;
    }

    Uint32List result = Uint32List(w * h);
    for (var yi = 0, sy = y; yi < h; ++yi, ++sy) {
      for (var xi = 0, sx = x; xi < w; ++xi, ++sx) {
        result[yi * w + xi] = this[sy * width + sx];
      }
    }

    return result;
  }

  void setCornerRadius({
    @required int width,
    @required int height,
    @required int radius,
    Color color,
  }) {
    assert(width != null && height != null && radius.isValideRadius);
    if (width == null || height == null || !radius.isValideRadius) return;
    //argb
    int colorValue = (color ?? Colors.transparent).value;
    //专成rgba
    // colorValue = ((colorValue & 0x00ffffff) << 8) | ((0xff000000 & colorValue) >> 24);
    //abgr
    colorValue = (colorValue & 0xff00ff00) | ((0x00ff0000 & colorValue) >> 16) | ((0x000000ff & colorValue) << 16);

    // 右下角中心点
    _Position rightBottomCenter = _Position(width - radius, height - radius);
    // 右上角中心点
    _Position rightTopCenter = _Position(width - radius, radius - 1);
    // 左上角中心点
    _Position leftTopCenter = _Position(radius - 1, radius - 1);
    // 左下角中心点
    _Position leftBottomCenter = _Position(radius - 1, height - radius);

    //圆弧和正方形对角线相交点的x坐标
    double seperatedX = sqrt(radius * radius / 2);

    void setPixelColor({
      @required _Position center,
      @required _Position relativePoint,
    }) {
      int x = center.x + relativePoint.x;
      int y = center.y + relativePoint.y;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        this[y * width + x] = colorValue;
      }
    }

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
        setPixelColor(
          center: rightBottomCenter,
          relativePoint: _Position(pixelX, pixelY),
        );
        if (pixelX != pixelY)
          setPixelColor(
            center: rightBottomCenter,
            relativePoint: _Position(pixelY, pixelX),
          );

        ///右上角
        setPixelColor(
          center: rightTopCenter,
          relativePoint: _Position(pixelX, -pixelY),
        );
        if (pixelX != pixelY)
          setPixelColor(
            center: rightTopCenter,
            relativePoint: _Position(pixelY, -pixelX),
          );

        ///左上角
        setPixelColor(
          center: leftTopCenter,
          relativePoint: _Position(-pixelX, -pixelY),
        );
        if (pixelX != pixelY)
          setPixelColor(
            center: leftTopCenter,
            relativePoint: _Position(-pixelY, -pixelX),
          );

        ///左下角
        setPixelColor(
          center: leftBottomCenter,
          relativePoint: _Position(-pixelX, pixelY),
        );
        if (pixelX != pixelY)
          setPixelColor(
            center: leftBottomCenter,
            relativePoint: _Position(-pixelY, pixelX),
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
}

mixin _CornerAndClipKeyMixin on AssetBundleImageKey {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  int get cornerRadius;
  //cornerRadius圆角外围部分的颜色
  Color get cornerColor;
  //缓存图片的大小
  int get cacheImageWidth;
  int get cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  ClipLocation get clipLocation;

  //显示出来的图片大小
  Size get imageShowSize;

  @override
  bool operator ==(Object other) {
    return other is _CornerAndClipKeyMixin &&
        super == other &&
        other.cornerRadius == cornerRadius &&
        (cornerRadius == null || other.cornerColor == cornerColor) &&
        other.cacheImageWidth == cacheImageWidth &&
        other.cacheImageHeight == cacheImageHeight &&
        other.imageShowSize == imageShowSize &&
        (imageShowSize == null || other.clipLocation == clipLocation);
  }

  @override
  int get hashCode => super.hashCode;
}

mixin _CornerAndClipProviderMixin<T> on ImageProvider<T> {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  int get cornerRadius;
  //cornerRadius圆角外围部分的颜色
  Color get cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  int get cacheImageWidth;
  int get cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  ClipLocation get clipLocation;

  //显示出来的图片大小
  Size get imageShowSize;

  @override
  ImageStreamCompleter load(key, DecoderCallback decode) {
    assert(cornerRadius.isValideRadius);
    final DecoderCallback decodeRoundCorners = (Uint8List bytes, {int cacheWidth, int cacheHeight, bool allowUpscaling}) async {
      int imageWidth;
      int imageHeight;
      bool customCacheSize = this.cacheImageWidth != null || this.cacheImageHeight != null;

      //图片解码
      Uint32List uint32List = await decode(
        bytes,
        cacheWidth: customCacheSize ? this.cacheImageWidth : cacheWidth,
        cacheHeight: customCacheSize ? this.cacheImageHeight : cacheHeight,
        allowUpscaling: false,
      ).then((value) async {
        var image = (await value.getNextFrame().catchError((onError) => null))?.image;
        if (image is ui.Image) {
          imageWidth = image.width;
          imageHeight = image.height;
          return (await image.toByteData(format: ui.ImageByteFormat.rawRgba).catchError((onError) => null))?.buffer?.asUint32List();
        }
        return null;
      }).catchError(
        (onError) => null,
      );

      if (uint32List == null) return decode(bytes, cacheWidth: cacheWidth, cacheHeight: cacheHeight, allowUpscaling: allowUpscaling ?? false);

      //圆角或者裁剪操作
      var result = await _isolateManager
          .send(
            _IsolateMessage(
              bytes: uint32List,
              cornerRadius: cornerRadius,
              color: cornerColor,
              imageWidth: imageWidth,
              imageHeight: imageHeight,
              clipLocation: clipLocation,
              showSize: imageShowSize,
            ),
          )
          .catchError((onError) => null);
      //将像素数组解码成图片数据
      if (result is _IsolateResult) {
        return _decodeImageFromPixels(result.bytes, result.width, result.height, ui.PixelFormat.rgba8888);
      } else {
        return _decodeImageFromPixels(uint32List.buffer.asUint8List(), imageWidth, imageHeight, ui.PixelFormat.rgba8888);
      }
    };

    if (cornerRadius.isValideRadius) {
      return super.load(key, decodeRoundCorners);
    } else {
      return super.load(key, decode);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is _CornerAndClipProviderMixin &&
        super == other &&
        other.cornerRadius == cornerRadius &&
        (cornerRadius == null || other.cornerColor == cornerColor) &&
        other.cacheImageWidth == cacheImageWidth &&
        other.cacheImageHeight == cacheImageHeight &&
        other.imageShowSize == imageShowSize &&
        (imageShowSize == null || other.clipLocation == clipLocation);
  }

  @override
  int get hashCode => super.hashCode;
}

class RoundCornersImageProvider {
  static RoundCornersNetworkImage network(
    String src, {
    double scale = 1.0,
    Map<String, String> headers,
    int cacheWidth,
    int cacheHeight,
    int cornerRadius,
    Color cornerColor,
    Size imageShowSize,
    ClipLocation clipLocation = ClipLocation.Center,
  }) {
    assert(cornerRadius.isValideRadius);
    return RoundCornersNetworkImage(
      src,
      scale: scale,
      headers: headers,
      cacheImageWidth: cacheWidth,
      cacheImageHeight: cacheHeight,
      cornerRadius: cornerRadius,
      cornerColor: cornerColor,
      imageShowSize: imageShowSize,
      clipLocation: clipLocation,
    );
  }

  static RoundCornerCachedNetworkImage cacheNetwork(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
    BaseCacheManager cacheManager,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    int cacheWidth,
    int cacheHeight,
    int cornerRadius,
    Color cornerColor,
    Size imageShowSize,
    ClipLocation clipLocation = ClipLocation.Center,
  }) {
    assert(cornerRadius.isValideRadius);
    return RoundCornerCachedNetworkImage(
      url,
      scale: scale,
      headers: headers,
      cacheManager: cacheManager,
      imageRenderMethodForWeb: imageRenderMethodForWeb,
      cacheImageWidth: cacheWidth,
      cacheImageHeight: cacheHeight,
      cornerRadius: cornerRadius,
      cornerColor: cornerColor,
      imageShowSize: imageShowSize,
      clipLocation: clipLocation,
    );
  }

  static ImageProvider file(
    File file, {
    double scale = 1.0,
    int cacheWidth,
    int cacheHeight,
    int cornerRadius,
    Color cornerColor,
    Size imageShowSize,
    ClipLocation clipLocation = ClipLocation.Center,
  }) {
    assert(cornerRadius.isValideRadius);
    return RoundCornersFileImage(
      file,
      scale: scale,
      cacheImageWidth: cacheWidth,
      cacheImageHeight: cacheHeight,
      cornerRadius: cornerRadius,
      cornerColor: cornerColor,
      imageShowSize: imageShowSize,
      clipLocation: clipLocation,
    );
  }

  static ImageProvider asset(
    String assetName, {
    AssetBundle bundle,
    double scale,
    int cacheWidth,
    int cacheHeight,
    int cornerRadius,
    Color cornerColor,
    Size imageShowSize,
    ClipLocation clipLocation = ClipLocation.Center,
  }) {
    assert(cornerRadius.isValideRadius);
    return scale != null
        ? RoundCornersExactAssetImage(
            assetName,
            scale: scale,
            cacheImageWidth: cacheWidth,
            cacheImageHeight: cacheHeight,
            cornerRadius: cornerRadius,
            cornerColor: cornerColor,
            imageShowSize: imageShowSize,
            clipLocation: clipLocation,
          )
        : RoundCornersAssetImage(
            assetName,
            cacheImageWidth: cacheWidth,
            cacheImageHeight: cacheHeight,
            cornerRadius: cornerRadius,
            cornerColor: cornerColor,
            imageShowSize: imageShowSize,
            clipLocation: clipLocation,
          );
  }

  static ImageProvider memory(
    Uint8List bytes, {
    AssetBundle bundle,
    double scale = 1.0,
    int cacheWidth,
    int cacheHeight,
    int cornerRadius,
    Color cornerColor,
    Size imageShowSize,
    ClipLocation clipLocation = ClipLocation.Center,
  }) {
    assert(cornerRadius.isValideRadius);
    return RoundCornersMemoryImage(
      bytes,
      scale: scale,
      cacheImageWidth: cacheWidth,
      cacheImageHeight: cacheHeight,
      cornerRadius: cornerRadius,
      cornerColor: cornerColor,
      imageShowSize: imageShowSize,
      clipLocation: clipLocation,
    );
  }
}

class RoundCornersExactAssetImage extends ExactAssetImage with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const RoundCornersExactAssetImage(
    String assetName, {
    double scale = 1.0,
    AssetBundle bundle,
    String package,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(assetName, bundle: bundle, scale: scale, package: package);

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return _WithCornerAssetBundleImageKey(
        bundle: value.bundle,
        name: value.name,
        scale: value.scale,
        cornerRadius: cornerRadius,
        cornerColor: cornerColor,
        cacheImageWidth: cacheImageWidth,
        cacheImageHeight: cacheImageHeight,
        clipLocation: clipLocation,
        imageShowSize: imageShowSize,
      );
    });
  }
}

class RoundCornersAssetImage extends AssetImage with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const RoundCornersAssetImage(
    String assetName, {
    AssetBundle bundle,
    String package,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(assetName, bundle: bundle, package: package);

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return _WithCornerAssetBundleImageKey(
        bundle: value.bundle,
        name: value.name,
        scale: value.scale,
        cornerRadius: cornerRadius,
        cornerColor: cornerColor,
        cacheImageWidth: cacheImageWidth,
        cacheImageHeight: cacheImageHeight,
        clipLocation: clipLocation,
        imageShowSize: imageShowSize,
      );
    });
  }
}

class _WithCornerAssetBundleImageKey extends AssetBundleImageKey with _CornerAndClipKeyMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const _WithCornerAssetBundleImageKey({
    @required AssetBundle bundle,
    @required String name,
    @required double scale,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(bundle: bundle, name: name, scale: scale);
}

class RoundCornersFileImage extends FileImage with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const RoundCornersFileImage(
    File file, {
    double scale = 1.0,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(file, scale: scale);
}

class RoundCornersMemoryImage extends MemoryImage with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const RoundCornersMemoryImage(
    Uint8List bytes, {
    double scale = 1.0,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(bytes, scale: scale);
}

class RoundCornersNetworkImage extends network_image.NetworkImage with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;

  const RoundCornersNetworkImage(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(url, scale: scale, headers: headers);
}

class RoundCornerCachedNetworkImage extends CachedNetworkImage.CachedNetworkImageProvider with _CornerAndClipProviderMixin {
  ///圆角，如果imageShowSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果imageShowSize为空，而cacheImageWidth或者cacheImageHeight不为空，则将resize之后的图片圆角设置为cornerRadius
  ///如果imageShowSize、cacheImageWidth、cacheImageHeight都为空，则将原图圆角设置为cornerRadius
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final int cacheImageWidth;
  final int cacheImageHeight;

  //imageShowSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部(上或左)截取宽高比为imageShowSize框高比的图片。
  final ClipLocation clipLocation;

  //显示出来的图片大小
  final Size imageShowSize;
  RoundCornerCachedNetworkImage(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
    BaseCacheManager cacheManager,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    this.cacheImageWidth,
    this.cacheImageHeight,
    this.imageShowSize,
    this.cornerRadius,
    this.cornerColor,
    this.clipLocation = ClipLocation.Center,
  })  : assert(cornerRadius != null && cornerRadius >= MinRadius),
        super(
          url,
          scale: scale,
          headers: headers,
          cacheManager: cacheManager,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
        );
}

Future _createRoundCornerIsolateMethod(dynamic info) async {
  if (info is _IsolateMessage) {
    if (info.bytes != null && info.cornerRadius.isValideRadius && info.imageWidth != null && info.imageHeight != null) {
      Uint32List uint32list = info.bytes;
      double clipRatio = info.showSize != null ? info.showSize.width / info.showSize.height : null;
      int resultImageWidth = clipRatio != null ? (clipRatio * info.imageHeight).toInt() : info.imageWidth;
      int resultImageHeight = info.imageHeight;
      //设置两个像素区间，以免相差一两个像素的也进行裁剪增加处理时间
      if ((resultImageWidth - info.imageWidth).abs() > 2) {
        ClipLocation location = info.clipLocation ?? ClipLocation.Center;
        //需要裁剪
        if (resultImageWidth < info.imageWidth) {
          //当前图片过宽了
          resultImageHeight = info.imageHeight;
          resultImageWidth = min((resultImageHeight * clipRatio).toInt(), info.imageWidth);
          int x;
          switch (location) {
            case ClipLocation.Start:
              x = 0;
              break;
            case ClipLocation.Center:
              x = (info.imageWidth - resultImageWidth) ~/ 2;
              break;
            case ClipLocation.End:
              x = info.imageWidth - resultImageWidth;
              break;
          }
          uint32list = uint32list.copyCrop(info.imageWidth, info.imageHeight, x, 0, resultImageWidth, resultImageHeight);
        } else {
          //当前图片过高了
          resultImageWidth = info.imageWidth;
          resultImageHeight = min(resultImageWidth ~/ clipRatio, resultImageHeight);
          int y = 0;
          switch (location) {
            case ClipLocation.Start:
              y = 0;
              break;
            case ClipLocation.Center:
              y = (info.imageHeight - resultImageHeight) ~/ 2;
              break;
            case ClipLocation.End:
              y = info.imageHeight - resultImageHeight;
              break;
          }
          uint32list = uint32list.sublist(y * resultImageWidth, (y + resultImageHeight) * resultImageWidth);
        }
      } else {
        resultImageWidth = info.imageWidth;
        resultImageHeight = info.imageHeight;
      }

      if (info.cornerRadius != null) {
        int radius = info.showSize == null ? info.cornerRadius : (info.cornerRadius * resultImageWidth) ~/ info.showSize.width;
        uint32list.setCornerRadius(width: resultImageWidth, height: resultImageHeight, radius: radius, color: info.color);
        return _IsolateResult(bytes: uint32list.buffer.asUint8List(), width: resultImageWidth, height: resultImageHeight);
      }
    } else {
      return _IsolateResult(bytes: info.bytes.buffer.asUint8List(), width: info.imageWidth, height: info.imageHeight);
    }
  }
  return null;
}

Future<ui.Codec> _decodeImageFromPixels(Uint8List pixels, int width, int height, ui.PixelFormat format) {
  return ui.ImmutableBuffer.fromUint8List(pixels).then((ui.ImmutableBuffer buffer) {
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: format,
    );

    return descriptor.instantiateCodec();
  });
}

class _IsolateMessage {
  final Uint32List bytes;
  //bytes代表的图片的宽高
  final int imageWidth;
  final int imageHeight;

  final int cornerRadius;
  final Color color;

  //clipRatio设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;
  //最终得到的图片的宽高比
  final Size showSize;

  _IsolateMessage({
    @required this.bytes,
    @required this.cornerRadius,
    this.color,
    @required this.imageWidth,
    @required this.imageHeight,
    this.clipLocation,
    this.showSize,
  }) : assert(
          bytes != null && cornerRadius.isValideRadius && imageWidth != null && imageHeight != null,
        );
}

class _IsolateResult {
  final Uint8List bytes;
  final int width;
  final int height;

  _IsolateResult({@required this.bytes, @required this.width, @required this.height}) : assert(bytes != null && width != null && height != null);
}
