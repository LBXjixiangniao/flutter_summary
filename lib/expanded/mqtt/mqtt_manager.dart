import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_summary/const/app_config.dart';
import 'package:flutter_summary/util/order_task_manager.dart';
import 'package:flutter_summary/util/util.dart';
import 'package:mqtt_client/mqtt_client.dart';

enum MQTTStatus {
  uploadInfo,
  connect,
  successConncet,
  subscribe,
  subscribeSubscribe,
  disconnect,
  subscribeFail,
}

/////stepID
const String InitStepID = 'InitStepID';
const String GetDeviceNameAndIDStepID = 'GetDeviceNameAndIDStepID';
const String UploadMqttInfoToServerStepID = 'UploadMqttInfoToServerStepID';
const String ConnectStepID = 'ConnectStepID';
const String SubscribeStepID = 'SubscribeStepID';

class MqttManager {
  OrderedTaskManager _mqttSettingTaskManager = OrderedTaskManager();
  MqttClient _mqttClient = MqttClient.withPort(MQTT_CONECT_HOST, '', 1883)..logging(on: Util.isInDebugMode);
  ValueChanged<Map<String, dynamic>> _receiveMessageHandle;
  StreamSubscription _streamSubscription;

  ///mqtt用到的唯一识别设备的uuid和设备名称
  String _deviceUuid;
  String get deviceUuid => _deviceUuid;
  String _deviceName = '';
  //mqtt上传信息给服务器用
  String _mqttUid;
  String get mqttUid => _mqttUid;
  String _mqttPassword;

  ///记录mqtt当前状态，主要用于测试查看mqtt状态
  MQTTStatus _mqttStatus;
  MQTTStatus get mqttStatus => _mqttStatus;

  ///记录最后ping成功时间
  String pingTime;

  ///判断是否手动断开连接
  bool _manualDisconnect = false;

  void setupMqtt({
    @required String uidStr,
    @required String pswStr,
  }) {
    _manualDisconnect = false;
    _mqttUid = uidStr;
    _mqttPassword = pswStr;
    if (_mqttPassword != null && _mqttUid != null && _deviceUuid != null) {
      _mqttSettingTaskManager.jumpToStep(UploadMqttInfoToServerStepID);
    }
  }

  //mqtt是否已经连接上了
  bool get isMqttConnected => _mqttClient.connectionStatus.state == MqttConnectionState.connected;

/////是否正在连接
  bool _isConnecting = false;

  MqttManager({ValueChanged<Map<String, dynamic>> receiveMessageHandle}) {
    _receiveMessageHandle = receiveMessageHandle;

    ///设置相关回调函数
    _mqttSettingTaskManager.addStepTask(
      StepTask(
        stepID: InitStepID,
        stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
          ////配置mqtt回调等信息
          _mqttClient.onSubscribed = _onMqttSubscribed;
          _mqttClient.onConnected = _onMqttConnected;
          _mqttClient.onDisconnected = _onMqttDisconnected;
          _mqttClient.onUnsubscribed = _onMqttUnsubscribed;
          _mqttClient.onSubscribeFail = _onMqttSubscribeFail;
          _mqttClient.logging(on: Util.isInDebugMode);
          _mqttClient.pongCallback = _mqttPong;
          _mqttClient.keepAlivePeriod = 10;
          runNext();
        },
      ),
    );

    ///获取设备相关信息
    _mqttSettingTaskManager.addStepTask(
      StepTask(
        stepID: GetDeviceNameAndIDStepID,
        stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
          ///获取设备uid和设备名称
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (Platform.isAndroid) {
            deviceInfo.androidInfo.then((onValue) {
              _deviceUuid = 'app_android_${onValue.androidId}';
              _deviceName = onValue.id;
              if (_mqttPassword != null && _mqttUid != null && _deviceUuid != null) {
                runNext();
              } else {
                finish();
              }
            });
          } else if (Platform.isIOS) {
            deviceInfo.iosInfo.then((onValue) {
              _deviceUuid = 'app_ios_${onValue.identifierForVendor}';
              _deviceName = onValue.name;
              if (_mqttPassword != null && _mqttUid != null && _deviceUuid != null) {
                runNext();
              } else {
                finish();
              }
            });
          }
          finish();
        },
      ),
    );

    ///上传信息到服务器
    _mqttSettingTaskManager.addStepTask(
      StepTask(
        stepID: UploadMqttInfoToServerStepID,
        stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
          _mqttStatus = MQTTStatus.uploadInfo;

          // ///上传mqtt相关信息
          // return NetworkApi.postSuccessOrFail(
          //   url: API_MQTT_REGISTER_FOR_PUSH,
          //   body: {
          //     "client": _deviceUuid ?? '',
          //     "devName": _deviceName ?? '',
          //     "password": _mqttPassword ?? '',
          //     "userName": _mqttUid ?? '',
          //     'registerId': _jpushRegisterID ?? ''
          //   },
          //   pathForData: null,
          // ).then((onValue) {
          //   runNext();
          // }).catchError((onError) {
          //   rerun();
          // });
        },
      ),
    );

    ///连接mqtt
    _mqttSettingTaskManager.addStepTask(
      StepTask(
        stepID: ConnectStepID,
        stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
          _mqttStatus = MQTTStatus.connect;

          ///连接mqtt
          _mqttClient.clientIdentifier = _deviceUuid;
          ////如果连接失败的话，会去到_onMqttDisconnected，所以此处不用处理连接失败的情况
          ///实时判断mqtt是否连上了
          if (!isMqttConnected) {
            _connectMqtt().then((value) {
              if (value) {
                runNext();
              } else {
                rerun();
              }
            });
          } else {
            runNext();
          }
        },
      ),
    );

    ///订阅mqtt
    _mqttSettingTaskManager.addStepTask(
      StepTask(
        stepID: SubscribeStepID,
        stepFunction: ({VoidCallback finish, VoidCallback rerun, VoidCallback runNext}) {
          _mqttStatus = MQTTStatus.subscribe;

          ///订阅mqtt
          _mqttClient.subscribe(_mqttUid ?? '', MqttQos.atLeastOnce);
          finish();
        },
      ),
    );

    _mqttSettingTaskManager.start();
  }

  void disconnect() {
    _manualDisconnect = true;
    _mqttClient.disconnect();
  }

//连接mqtt
  Future<bool> _connectMqtt() async {
    try {
      _isConnecting = true;
      await _mqttClient.connect(_mqttUid, _mqttPassword);
      _isConnecting = false;
    } on Exception catch (_) {
      _isConnecting = false;
      _mqttClient.disconnect();
    } catch (_) {
      _isConnecting = false;
      _mqttClient.disconnect();
    }

    /// Check we are connected
    if (_mqttClient.connectionStatus.state == MqttConnectionState.connected) {
      _streamSubscription?.cancel();

      ///监听服务器发来的信息
      _streamSubscription = _mqttClient.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        c?.forEach((f) {
          ///服务器返回的数据信息
          dynamic message = (f.payload as MqttPublishMessage).payload.message;
          String pt;
          try {
            pt = Utf8Codec().decode(message);
          } catch (e) {}
          if (pt != null) {
            JsonUtf8Encoder(pt);
            Map<String, dynamic> tmpMap = jsonDecode(pt);
            if (tmpMap is Map) {
              if (_receiveMessageHandle != null) {
                _receiveMessageHandle(tmpMap);
              }
            } else {
              // JpushManager().records.add('Error MQTT Message:${tmpMap?.toString()}');
            }
          }
        });
      });
      return true;
    } else {
      /// Use status here rather than state if you also want the broker return code.
      _mqttClient.disconnect();
      return false;
    }
  }

  ////////Mqtt回调
  /// The subscribed callback
  void _onMqttSubscribed(String topic) {
    // logger.v('EXAMPLE::Subscription confirmed for topic $topic');
  }

  ///订阅失败
  void _onMqttSubscribeFail(String topic) {
    _mqttStatus = MQTTStatus.subscribeFail;

    ///尝试重新订阅
    Future.delayed(Duration(seconds: 5), () {
      _mqttSettingTaskManager.jumpToStep(SubscribeStepID);
    });
    // logger.v('EXAMPLE::Subscription fail for topic $topic');
  }

  ///取消订阅
  void _onMqttUnsubscribed(String topic) {
    // logger.v('EXAMPLE::Unsubscribed confirmed for topic $topic');
  }

  ///未经请求的断开连接
  /// The unsolicited disconnect callback
  void _onMqttDisconnected() {
    _mqttStatus = MQTTStatus.disconnect;
    // logger.v('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_mqttClient.connectionStatus.returnCode == MqttConnectReturnCode.solicited) {
      // logger.v('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }

    //尝试重连
    if (!_manualDisconnect && !_isConnecting) {
      _mqttSettingTaskManager.jumpToStep(ConnectStepID);
    }
  }

  /// The successful connect callback
  void _onMqttConnected() {
    _mqttStatus = MQTTStatus.successConncet;
    // logger.v('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  /// Pong callback
  void _mqttPong() {
    assert((pingTime = DateTime.now().toIso8601String()) != null);
    // logger.v('EXAMPLE::Ping response client callback invoked');
  }
}
