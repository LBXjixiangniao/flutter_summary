import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:flutter/material.dart';

class Util {
  //md5加密
  static String generateMd5(String data, {bool addSalt = false}) {
    String salt = 'com.sunfly.www';
    var content = new Utf8Encoder().convert(addSalt == true ? data + salt : data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  //16位md5加密
  static String generate16BitMd5(String data, {bool addSalt = false}) {
    String salt = 'com.sunfly.www';
    var content = new Utf8Encoder().convert(addSalt == true ? data + salt : data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()

    return hex.encode(digest.bytes).substring(8, 24);
  }

  static dynamic mapValueForPath(dynamic map, List pathForData) {
    int pathLenght = pathForData?.length ?? 0;
    dynamic data = map;
    for (int i = 0; i < pathLenght; i++) {
      if (data is Map) {
        data = data[pathForData[i]];
        if (data == null) {
          return null;
        }
      } else {
        return null;
      }
    }
    return data;
  }

  static int daysForMonth({@required int year, @required int month}) {
    assert(year != null && month != null);
    if (month == 12) {
      return 31;
    } else {
      return DateTime(year, month, 0).day;
    }
  }

  static bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
