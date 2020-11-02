import 'package:flutter/material.dart';

import 'color_helper.dart';

class PingFangType {
  static String get bold => 'PingFangBold';
  static String get medium => 'PingFangMedium';
  static String get regular => 'PingFang';
}

class CustomTextStyle {
   static TextStyle get h1 => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get h2Bold => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get h2 => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 16,
        color: ColorHelper.PrimaryTextColor,
      );

   static TextStyle get bodyBold => TextStyle(
        fontFamily: PingFangType.regular,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get body => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 14,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get bodyLight => TextStyle(
        fontFamily: PingFangType.regular,
        fontSize: 14,
        color: ColorHelper.AssistTextColor,
      );

   static TextStyle get summary => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 12,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get summaryLight => TextStyle(
        fontFamily: PingFangType.regular,
        fontSize: 12,
        color: ColorHelper.AssistTextColor,
      );

   static TextStyle get caption => TextStyle(
        fontFamily: PingFangType.medium,
        fontSize: 11,
        color: ColorHelper.PrimaryTextColor,
      );
   static TextStyle get captionLight => TextStyle(
        fontFamily: PingFangType.regular,
        fontSize: 11,
        color: ColorHelper.AssistTextColor,
      );
}
