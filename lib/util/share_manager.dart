import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_summary/const/app_config.dart';
import 'package:flutter_summary/widgets/toast.dart';
import 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_qq/flutter_qq.dart';
// import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:url_launcher/url_launcher.dart';

export 'package:jshare_flutter_plugin/jshare_flutter_plugin.dart';

enum DoorPasswdShareType {
  Copy,
  QQ,
  WeChat,
  Message,
}

class ShareManager {
  static void init() {
    JShareConfig shareConfig = new JShareConfig(appKey: JIGUANG_PUSH_OR_SHARE_APP_KEY);

    shareConfig.channel = "channel";
    shareConfig.isDebug = true;
    shareConfig.isAdvertisinId = true;
    shareConfig.isProduction = true;

    shareConfig.weChatAppId = WECHAT_APP_ID;
    shareConfig.weChatAppSecret = WECHAT_SECRET;

    shareConfig.qqAppId = QQ_SHARE_APP_ID;
    shareConfig.qqAppKey = QQ_SHARE_KEY;

    // shareConfig.sinaWeiboAppKey = "374535501";
    // shareConfig.sinaWeiboAppSecret = "baccd12c166f1df96736b51ffbf600a2";
    // shareConfig.sinaRedirectUri = "https://www.jiguang.cn";

    // shareConfig.facebookAppID = "1847959632183996";
    // shareConfig.facebookDisplayName = "JShareDemo";

    // shareConfig.twitterConsumerKey = "4hCeIip1cpTk9oPYeCbYKhVWi";
    // shareConfig.twitterConsumerSecret =
    //     "DuIontT8KPSmO2Y1oAvby7tpbWHJimuakpbiAUHEKncbffekmC";

    JShare().setup(config: shareConfig);
  }

  static Future<dynamic> shareApp(JSharePlatform shareType) async {
    JShareMessage message = JShareMessage();
    message.title = '慧昇活';
    message.text = '慧昇活下载链接';
    message.url = ShareManager.urlForApp;
    message.mediaType = JShareType.link;
    message.imagePath = await _tempSaveImage('icon.png', 'images/icon_thumbnail.png');
    message.platform = shareType;
    return JShare().shareMessage(message: message).then((value) {
      _tempDeleteImage('icon.png');
      return value;
    });
  }

  static Future<dynamic> shareTemporaryDoorPassword(String passwd, DoorPasswdShareType type, String deviceId) async {
    assert(passwd != null && type != null && deviceId != null);
    String shareText = '【慧昇活】您的好友/亲人分享智能门锁临时密码：$passwd';
    try {
      switch (type) {
        case DoorPasswdShareType.Copy:
          {
            ClipboardData data = new ClipboardData(text: passwd);
            return Clipboard.setData(data).then((value) {
              return true;
            });
          }
        case DoorPasswdShareType.QQ:
          {
            return checkIfInstalled(JSharePlatform.qq).then((value) async {
              if (value) {
                JShareMessage message = JShareMessage();
                message.title = '门锁临时密码';
                message.text = shareText;
                if (Platform.isAndroid) {
                  message.mediaType = JShareType.link;
                  message.url = urlForApp;
                  // message.imagePath = await _tempSaveImage('icon.png', 'images/icon_thumbnail.png');
                } else {
                  message.mediaType = JShareType.text;
                }
                message.platform = JSharePlatform.qq;
                return JShare().shareMessage(message: message).then((value) {
                  return value.code == JShareCode.success;
                });
              }
              return false;
            });
          }
        case DoorPasswdShareType.WeChat:
          {
            return checkIfInstalled(JSharePlatform.wechatSession).then((value) {
              if (value) {
                JShareMessage message = JShareMessage();
                // message.title = '门锁临时密码';
                message.text = shareText;
                message.mediaType = JShareType.text;

                message.platform = JSharePlatform.wechatSession;
                return JShare().shareMessage(message: message).then((value) {
                  return value.code == JShareCode.success;
                });
              }
              return false;
            });
          }
        case DoorPasswdShareType.Message:
          {
            String messagebody = Uri.encodeComponent(shareText);
            String url;
            if (Platform.isAndroid) {
              url = 'sms:?body=$messagebody';
            } else if (Platform.isIOS) {
              url = 'sms:&body=$messagebody';
            }
            if (await canLaunch(url)) {
              return launch(url);
            } else {
              CustomToast.showShort('短信分享失败');
            }
          }
      }
    } catch (error) {
      CustomToast.showShort('分享失败');
      return false;
    }
    return false;
  }

  static Future<bool> checkIfInstalled(JSharePlatform platform) {
    return JShare().isClientValid(platform: platform).then((value) {
      if (!value) {
        String tips = '';
        switch (platform) {
          case JSharePlatform.wechatSession:
          case JSharePlatform.wechatTimeLine:
          case JSharePlatform.wechatFavourite:
            tips = '微信';
            break;
          case JSharePlatform.qq:
          case JSharePlatform.qZone:
            tips = 'QQ';
            break;
          case JSharePlatform.sinaWeibo:
          case JSharePlatform.sinaWeiboContact:
            tips = '微博';
            break;
          case JSharePlatform.facebook:
          case JSharePlatform.facebookMessenger:
            tips = 'facebook';
            break;
          case JSharePlatform.twitter:
            tips = 'twitter';
            break;
        }
        CustomToast.showShort('请先安装$tips');
      }
      return value;
    });
  }

  static String get urlForApp => 'http://www.sunflyflat.com/app/index.html';

  //  {
  //   if (Platform.isIOS) {
  //     return "https://itunes.apple.com/cn/app/id1490227691";
  //   } else if (Platform.isAndroid) {
  //     return "https://sj.qq.com/myapp/detail.htm?apkName=com.sunfly.smart_life_app";
  //   }
  // }

  static Future<String> _tempSaveImage(String imageName, String imagePath) async {
    print("Action - _tempSaveTestImage:");
    final Directory directory = await getTemporaryDirectory();

    Uint8List bytes = await _getAssetsImageBytes(imagePath);
    String path = await _saveFile(directory, imageName, bytes);

    return path;
  }

  /// 删除图片
  static void _tempDeleteImage(String imageName) async {
    print("Action - _tempDeleteTestImage:");
    final Directory directory = await getTemporaryDirectory();
    _deleteFile(directory, imageName);
  }

  /// 获取 assets里的图片（测试暂时用 assets 里的）
  static Future<Uint8List> _getAssetsImageBytes(String imagePath) async {
    print("Action - getAssetsImageBytes:" + imagePath);

    ByteData byteData = await rootBundle.load(imagePath);
    Uint8List uint8list = byteData.buffer.asUint8List();

    return uint8list;
  }

  /// 存储文件
  static Future<String> _saveFile(Directory directory, String name, Uint8List bytes) async {
    print("Action - _saveFile:" + "directory:" + directory.toString() + ",name:" + name);
    final File file = File('${directory.path}/$name');

    if (file.existsSync()) {
      file.deleteSync();
    }

    File file1 = await file.writeAsBytes(bytes);

    // if(file1.existsSync()) {
    //   print('====保存成功');
    // }else{
    //   print('====保存失败');
    // }
    return file1.path;
  }

  /// 删除文件
  static void _deleteFile(Directory directory, String name) {
    print("Action - _deleteFile:");
    final File file = File('${directory.path}/$name');

    if (file.existsSync()) {
      file.deleteSync();
    }
  }
}
