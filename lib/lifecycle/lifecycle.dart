import 'package:flutter/material.dart';

class LifeCycle with WidgetsBindingObserver {
  /**
   * app的生命周期回调，如进入后台或者从后台进入前台
   */
  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        // JpushManager().resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // JpushManager().stop();
        break;
    }
  }

///App 初始化
  static initApp() async {
    // ShareManager.init();
  }

///请求相关权限，会弹出权限确认框
  static askForPermission() {
    Future(() async {
      // await Permission.camera.request().then((value) {});
      // await Permission.contacts.request().then((value) {});
      // if (Platform.isAndroid) {
      //   await Permission.locationWhenInUse.request().then((value) {});
      // } else {
      //   LocationManager().init();
      // }
      // JpushManager().init();
    });
  }

/**
 * 登录，可以按实际需要添加参数
 */
  static loginIn(){

  }
/**
 * 退出登录，可以按实际需要添加参数
 */
  static loginOut(){

  }
}

