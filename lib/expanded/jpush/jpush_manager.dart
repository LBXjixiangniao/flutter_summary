// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_summary/const/app_config.dart';
// import 'package:flutter_summary/util/order_task_manager.dart';
// import 'package:flutter_summary/util/util.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';

// enum JpushType {
//   Message,
//   Notification,
//   Open,
// }

// /////stepID
// const String InitStepID = 'InitStepID';
// const String SetupStepID = 'SetupStepID';
// const String CheckIfSetupSuccessStepID = 'CheckIfSetupSuccessStepID';
// const String SetAliasStepID = 'SetAliasStepID';

// class JpushManager {
//   factory JpushManager() => _instance;

//   static final JpushManager _instance = JpushManager._();

//   final OrderedTaskManager _jpushSettingTaskManager = OrderedTaskManager();

//   String _alias;
//   String get jpushAlias => _alias;

//   String _registrationID;
//   String get jpushRegistrationID => _registrationID;

//   ///传入进来的用户uid，用于设置alias
//   String _uid;
//   String _password;

//   //用于判断JpushManager是否已经初始化过了
//   bool _isJpushManagerInit = false;
//   //TEST_CODE 测试用状态记录
//   // bool toastJpush = false;
//   // String get jpushToastStr =>
//   //     'mqttStatus:${_mqttManager.mqttStatus}\nalias:${JpushManager().jpushAlias}\nregistrationID::${JpushManager().jpushRegistrationID}' +
//   //     '\nmqttConnected:${_mqttManager.isMqttConnected}\nuserUid:${_mqttManager.mqttUid}\ndeviceUuid:${_mqttManager.deviceUuid}\npingTime:${_mqttManager.pingTime}';
//   // ListQueue records = ListQueue();

//   JpushManager._() {
//     ///初始化极光，设置消息处理回调
//     _jpushSettingTaskManager.addStepTask(
//       StepTask(
//         stepID: InitStepID,
//         stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
//           ///初始化
//           _isJpushManagerInit = true;
//           JPush jpush = new JPush();
//           //申请权限
//           jpush.applyPushAuthority();
//           //清除通知栏上所有通知
//           jpush.clearAllNotifications();

//           //添加回调
//           jpush.addEventHandler(
//             onReceiveNotification: (Map<String, dynamic> message) async {
//               JpushManager._message(message, JpushType.Notification);
//             },
//             onOpenNotification: (Map<String, dynamic> message) async {
//               // 点击通知栏消息，在此时通常可以做一些页面跳转等
//               JpushManager._message(message, JpushType.Open);
//             },
//             onReceiveMessage: (Map<String, dynamic> message) async {
//               JpushManager._message(message, JpushType.Message);
//             },
//           );
//           runNext?.call();
//         },
//       ),
//     );

//     ///极光setup，设置appKey
//     _jpushSettingTaskManager.addStepTask(
//       StepTask(
//         stepID: SetupStepID,
//         stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
//           ///设置key之类的
//           JPush jpush = new JPush();
//           jpush.setup(
//             appKey: JIGUANG_PUSH_OR_SHARE_APP_KEY,
//             channel: "developer-default",
//             production: false,
//             debug: Util.isInDebugMode, // 设置是否打印 debug 日志
//           );

//           if (_uid != null) {
//             ///自动执行下一步
//             runNext?.call();
//           } else {
//             //不再自动执行执行下一步
//             finish?.call();
//           }
//         },
//       ),
//     );

//     ///通过RegistrationID判断极光是否注册成功，成功就执行下一步，不成功就重复执行注册方法
//     _jpushSettingTaskManager.addStepTask(
//       StepTask(
//         stepID: CheckIfSetupSuccessStepID,
//         stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
//           JPush jpush = new JPush();
//           if (_registrationID == null) {
//             jpush.getRegistrationID().then((onValue) {
//               if (onValue is String) {
//                 //注册成功
//                 _registrationID = onValue;
//                 runNext?.call();
//               } else {
//                 //未注册成功
//                 finish?.call();
//                 _jpushSettingTaskManager.jumpToStep(SetupStepID);
//               }
//             });
//           } else {
//             runNext?.call();
//           }
//         },
//       ),
//     );

//   ///设置别名alias
//     _jpushSettingTaskManager.addStepTask(
//       StepTask(
//         stepID: SetAliasStepID,
//         stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
//           if (_uid == null) {
//             _jpushSettingTaskManager.stop();
//             rerun?.call();
//           }
//           JPush jpush = new JPush();
//           jpush.setAlias(_uid).then((map) {
//             _alias = Util.mapValueForPath(map, ['alias']);
//             if (_alias is String && _alias.length > 0) {
//               runNext?.call();
//             } else {
//               rerun?.call();
//             }
//           }).catchError((onError) {
//             rerun?.call();
//           });
//         },
//       ),
//     );
//   }

//   void init() {
//     if (_isJpushManagerInit != true) {
//       _jpushSettingTaskManager.start();
//     }
//   }

//   ///password是登陆用的密码的密文的md5
//   void setupRegister({@required String uid, @required String password}) {
//     if (uid != null) {
//       _uid = uid;
//       _jpushSettingTaskManager.jumpToStep(CheckIfSetupSuccessStepID);
//     }
//     _password = password;
//   }

//   void resume() {
//     JPush jpush = new JPush();
//     jpush.resumePush();
//   }

//   ///断开mqtt连接和删除极光的alias
//   void disconnect() {
//     _deleteAlias();
//   }

//   void _deleteAlias([Function(Map<dynamic, dynamic>) completeCallBack]) {
//     _alias = null;
//     JPush jpush = new JPush();
//     jpush.deleteAlias().then((onValue) {
//       if (completeCallBack != null) {
//         completeCallBack(onValue);
//       }
//     }).catchError((onError) {
//       if (completeCallBack != null) {
//         completeCallBack(null);
//       }
//     });
//   }

//   /**
//   * 处理极光的消息
//   */

//   static _message(Map<String, dynamic> message, JpushType type) async {}
// }
