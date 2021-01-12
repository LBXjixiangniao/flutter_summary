import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as IMG;
import 'package:flutter_summary/main/performance/widgets/round_corners_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter/src/painting/_network_image_io.dart'
    if (dart.library.html) 'package:flutter/src/painting/_network_image_web.dart' as network_image;

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

class RoundCornersExactAssetImage extends ExactAssetImage {
  final int cornerRadius;
  const RoundCornersExactAssetImage(
    String assetName, {
    double scale = 1.0,
    AssetBundle bundle,
    String package,
    this.cornerRadius,
  }) : super(assetName, bundle: bundle, scale: scale, package: package);

  @override
  ImageStreamCompleter load(AssetBundleImageKey key, DecoderCallback decode) {
    return super.load(key, decode);
  }

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return WithCornerAssetBundleImageKey(cornerRadius: cornerRadius, bundle: value.bundle, name: value.name, scale: value.scale);
    });
  }
}

class RoundCornersAssetImage extends AssetImage {
  final int cornerRadius;
  const RoundCornersAssetImage(
    String assetName, {
    AssetBundle bundle,
    String package,
    this.cornerRadius,
  }) : super(assetName, bundle: bundle, package: package);

  @override
  ImageStreamCompleter load(AssetBundleImageKey key, DecoderCallback decode) {
    final DecoderCallback decodeRoundCorners =
        (Uint8List bytes, {int cacheWidth, int cacheHeight, bool allowUpscaling}) {
      IMG.Image imageInfo = IMG.decodeImage(bytes);
      debugPrint('load:${Isolate.current.debugName}');
      imageInfo.createRoundCorners(image: imageInfo, radius: cornerRadius, color: Colors.red);
      return decode(IMG.encodePng(imageInfo),
          cacheWidth: cacheWidth, cacheHeight: cacheHeight, allowUpscaling: allowUpscaling ?? false);
    };
    return super.load(key, decodeRoundCorners);
  }

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((value) {
      return WithCornerAssetBundleImageKey(cornerRadius: cornerRadius, bundle: value.bundle, name: value.name, scale: value.scale);
    });
  }
}

class WithCornerAssetBundleImageKey extends AssetBundleImageKey {
  final int cornerRadius;
  WithCornerAssetBundleImageKey(
      {@required AssetBundle bundle, @required String name, @required double scale, @required this.cornerRadius})
      : super(bundle: bundle, name: name, scale: scale);

  @override
  bool operator ==(Object other) {
    return other is WithCornerAssetBundleImageKey && super == other && other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode => hashValues(super.hashCode, cornerRadius);
}

class RoundCornersFileImage extends FileImage {
  const RoundCornersFileImage(
    File file, {
    double scale = 1.0,
  }) : super(file, scale: scale);
}

class RoundCornersMemoryImage extends MemoryImage {
  const RoundCornersMemoryImage(
    Uint8List bytes, {
    double scale = 1.0,
  }) : super(bytes, scale: scale);
}

class RoundCornersNetworkImage extends network_image.NetworkImage {
  const RoundCornersNetworkImage(
    String url, {
    double scale = 1.0,
    Map<String, String> headers,
  }) : super(url, scale: scale, headers: headers);
}
