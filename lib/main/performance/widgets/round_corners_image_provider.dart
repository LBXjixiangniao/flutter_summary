import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/src/image_provider/_image_provider_io.dart'
    if (dart.library.html) 'package:cached_network_image/src/image_provider/_image_provider_web.dart'
    as CachedNetworkImage;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as IMG;
import 'package:flutter_summary/main/performance/widgets/round_corners_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter/src/painting/_network_image_io.dart'
    if (dart.library.html) 'package:flutter/src/painting/_network_image_web.dart' as network_image;

import 'isolate_manager.dart';

final IsolateManager _isolateManager =
    IsolateManager(isolateFunction: _createRoundCornerIsolateMethod, reverseOrder: true, keepRunning: true);

enum ClipLocation {
  Start,
  Center,
  End,
}

mixin CornerAndClipKeyMixin on AssetBundleImageKey {
  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  int get cornerRadius;
  //cornerRadius圆角外围部分的颜色
  Color get cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  double get showWidth;
  double get showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  ClipLocation get clipLocation;

  bool get haveValidShowSize => showWidth != null && showHeight != null;

  @override
  bool operator ==(Object other) {
    return other is CornerAndClipKeyMixin &&
        super == other &&
        other.cornerRadius == cornerRadius &&
        (cornerRadius == null || other.cornerColor == cornerColor) &&
        other.haveValidShowSize == haveValidShowSize &&
        (haveValidShowSize
            ? (other.showHeight == showHeight && other.showWidth == showWidth && other.clipLocation == clipLocation)
            : true);
  }

  @override
  int get hashCode => hashValues(super.hashCode, cornerRadius, haveValidShowSize);
}

mixin CornerAndClipProviderMixin<T> on ImageProvider<T> {
  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  int get cornerRadius;
  //cornerRadius圆角外围部分的颜色
  Color get cornerColor;
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  double get showWidth;
  double get showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  ClipLocation get clipLocation;

  @override
  ImageStreamCompleter load(key, DecoderCallback decode) {
    final DecoderCallback decodeRoundCorners =
        (Uint8List bytes, {int cacheWidth, int cacheHeight, bool allowUpscaling}) async {
      assert(() {
        print('CornerAndClipProviderMixin load');
        return true;
      }());
      Uint8List uint8List;
      if (cornerRadius != null ||
          (showWidth != null &&
              showHeight != null &&
              showHeight > 0 &&
              showWidth > 0 &&
              showHeight != double.nan &&
              showHeight != double.infinity &&
              showWidth != double.nan &&
              showWidth != double.infinity)) {
        var tmpUint8List = await _isolateManager.send(
          _IsolateMessage(
            bytes: bytes,
            cornerRadius: cornerRadius,
            color: cornerColor,
            showHeight: showHeight,
            showWidth: showWidth,
            clipLocation: clipLocation,
          ),
        );
        if (tmpUint8List is Uint8List) {
          uint8List = tmpUint8List;
        }
      }
      uint8List ??= bytes;
      return decode(uint8List,
          cacheWidth: cacheWidth, cacheHeight: cacheHeight, allowUpscaling: allowUpscaling);
    };
    return super.load(key, decodeRoundCorners);
  }

  bool get haveValidShowSize => showWidth != null && showHeight != null;

  @override
  bool operator ==(Object other) {
    return other is CornerAndClipProviderMixin &&
        super == other &&
        other.cornerRadius == cornerRadius &&
        (cornerRadius == null || other.cornerColor == cornerColor) &&
        other.haveValidShowSize == haveValidShowSize &&
        (haveValidShowSize
            ? (other.showHeight == showHeight && other.showWidth == showWidth && other.clipLocation == clipLocation)
            : true);
  }

  @override
  int get hashCode => hashValues(super.hashCode, cornerRadius, haveValidShowSize);
}

class RoundCornersImageProvider {
  static ImageProvider network(
    String src, {
    double scale = 1.0,
    Map<String, String> headers,
    int cacheWidth,
    int cacheHeight,
  }) {}
  static ImageProvider file(
    File file, {
    double scale = 1.0,
    Map<String, String> headers,
    int cacheWidth,
    int cacheHeight,
  }) {}
  static ImageProvider asset(
    File file, {
    AssetBundle bundle,
    double scale,
    Map<String, String> headers,
    int cacheWidth,
    int cacheHeight,
  }) {}
  static ImageProvider memory(
    Uint8List bytes, {
    AssetBundle bundle,
    double scale = 1.0,
    Map<String, String> headers,
    int cacheWidth,
    int cacheHeight,
  }) {}
}

class RoundCornersExactAssetImage extends ExactAssetImage with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;

  const RoundCornersExactAssetImage(
    String assetName, {
    double scale = 1.0,
    AssetBundle bundle,
    String package,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(assetName, bundle: bundle, scale: scale, package: package);

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return WithCornerAssetBundleImageKey(
        cornerRadius: cornerRadius,
        bundle: value.bundle,
        name: value.name,
        scale: value.scale,
        clipLocation: clipLocation,
        showHeight: showHeight,
        showWidth: showWidth,
        cornerColor: cornerColor,
      );
    });
  }
}

class RoundCornersAssetImage extends AssetImage with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;

  const RoundCornersAssetImage(
    String assetName, {
    AssetBundle bundle,
    String package,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(assetName, bundle: bundle, package: package);

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return WithCornerAssetBundleImageKey(
        cornerRadius: cornerRadius,
        bundle: value.bundle,
        name: value.name,
        scale: value.scale,
        clipLocation: clipLocation,
        showHeight: showHeight,
        showWidth: showWidth,
        cornerColor: cornerColor,
      );
    });
  }
}

class WithCornerAssetBundleImageKey extends AssetBundleImageKey with CornerAndClipKeyMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;
  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;

  const WithCornerAssetBundleImageKey(
      {@required AssetBundle bundle,
      @required String name,
      @required double scale,
      @required this.cornerRadius,
      @required this.cornerColor,
      @required this.showHeight,
      @required this.showWidth,
      @required this.clipLocation})
      : super(bundle: bundle, name: name, scale: scale);
}

class RoundCornersFileImage extends FileImage with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  const RoundCornersFileImage(
    File file, {
    double scale = 1.0,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(file, scale: scale);
}

class RoundCornersMemoryImage extends MemoryImage with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;

  const RoundCornersMemoryImage(
    Uint8List bytes, {
    double scale = 1.0,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(bytes, scale: scale);
}

class RoundCornersNetworkImage extends network_image.NetworkImage with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  const RoundCornersNetworkImage(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(url, scale: scale, headers: headers);
  @override
  Future<network_image.NetworkImage> obtainKey(ImageConfiguration configuration) {
    // TODO: implement obtainKey
    return super.obtainKey(configuration);
  }
}

class RoundCornerCachedNetworkImage extends CachedNetworkImage.CachedNetworkImageProvider
    with CornerAndClipProviderMixin {
  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;

  //showWidth、showHeight设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  ///圆角，如果showSize不为空，则通过计算使得显示出来的图片圆角为cornerRadius，
  ///如果showSize为空，直接对图片设置圆角
  final int cornerRadius;
  //cornerRadius圆角外围部分的颜色
  final Color cornerColor;
  RoundCornerCachedNetworkImage(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
    BaseCacheManager cacheManager,
    ImageRenderMethodForWeb imageRenderMethodForWeb,
    this.cornerRadius,
    this.cornerColor,
    this.showHeight,
    this.showWidth,
    this.clipLocation = ClipLocation.Center,
  }) : super(
          url,
          scale: scale,
          headers: headers,
          cacheManager: cacheManager,
          imageRenderMethodForWeb: imageRenderMethodForWeb,
        );
}

Future _createRoundCornerIsolateMethod(dynamic info) async {
  if (info is _IsolateMessage &&
      ((info.showHeight != null && info.showHeight > 0 && info.showWidth != null && info.showWidth > 0) ||
          info.cornerRadius != null)) {
    IMG.Image imageInfo = IMG.decodeImage(info.bytes);
    double scale;
    if (info.showHeight != null &&
        info.showHeight > 0 &&
        info.showWidth != null &&
        info.showWidth > 0 &&
        info.showHeight != double.nan &&
        info.showHeight != double.infinity &&
        info.showWidth != double.nan &&
        info.showWidth != double.infinity) {
      scale = min(imageInfo.height / info.showHeight, imageInfo.width / info.showWidth);
      int targetHeight = (info.showHeight * scale).toInt();
      int targetWidth = (info.showWidth * scale).toInt();
      if (imageInfo.height - targetHeight > 2) {
        //原图偏高了
        ClipLocation location = info.clipLocation ?? ClipLocation.Center;
        int x = 0;
        int y;
        switch (location) {
          case ClipLocation.Start:
            y = 0;
            break;
          case ClipLocation.Center:
            y = (imageInfo.height - targetHeight) ~/ 2;
            break;
          case ClipLocation.End:
            y = imageInfo.height - targetHeight;
            break;
        }
        imageInfo = IMG.copyCrop(imageInfo, x, y, imageInfo.width, targetHeight);
      } else if (imageInfo.width - targetWidth > 2) {
        //原图偏宽了
        ClipLocation location = info.clipLocation ?? ClipLocation.Center;
        int x;
        int y = 0;
        switch (location) {
          case ClipLocation.Start:
            x = 0;
            break;
          case ClipLocation.Center:
            x = (imageInfo.width - targetWidth) ~/ 2;
            break;
          case ClipLocation.End:
            x = imageInfo.width - targetWidth;
            break;
        }
        imageInfo = IMG.copyCrop(imageInfo, x, y, targetWidth, imageInfo.height);
      }
    }
    if (info.cornerRadius != null) {
      int radius = scale == null ? info.cornerRadius : (info.cornerRadius * scale).toInt();
      imageInfo.setRoundCorners(radius: radius, color: info.color);
    }

    return IMG.encodePng(imageInfo);
  }
  return null;
}

class _IsolateMessage {
  final Uint8List bytes;
  final int cornerRadius;
  final Color color;

  //图片显示的大小，如果设置了图片显示宽高，会按图片显示宽高比截取原图
  final double showWidth;
  final double showHeight;
  //showSize设置后裁取的位置
  //如果设置ClipLocation.Start，则当原始图片过长的时候从头部截取宽高比为clipRatio的图片。
  final ClipLocation clipLocation;

  _IsolateMessage({
    @required this.bytes,
    this.cornerRadius,
    this.color,
    this.showHeight,
    this.showWidth,
    this.clipLocation,
  });
}
