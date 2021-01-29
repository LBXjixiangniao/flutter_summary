import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

typedef IsolateFunction = Future Function(dynamic message);

class IsolateInfo {
  final Isolate isolate;
  SendPort sendPort;

  IsolateInfo({this.isolate, this.sendPort});
}

class _Action {
  final dynamic message;
  final Completer completer;

  _Action({this.message, this.completer});
}

///传递到Isolate中的信息，
///function：是创建IsolateManager的时候外部传递的用于接收value并返回结果
class _MessageInfo {
  final IsolateFunction function;
  final dynamic value;

  _MessageInfo({@required this.function, @required this.value});
}

/**
 * 用于管理一个或多个Isolate协同进行异步操作
 * maxCocurrentIsolateCount：最大允许同时运行的Isolate数量
 * isolateFunction：接收send方法的message进行处理，并返回结果，运行在isolate中
 * reverseOrder：是否倒叙处理send方法传递的message
 */
class IsolateManager {
  //如果reverseOrder为true，则后加入的事件先执行
  final bool reverseOrder;
  //最大允许同时运行Isolate数
  final int maxCocurrentIsolateCount;
  //当前运行Isolate数
  int _currentIsolateCount = 0;
  //待处理的事件
  List<_Action> _penddingActionList = [];
  //正在处理的事件
  Map<Isolate, _Action> _processingActionList = {};

  // The function must be a top-level function or a static method
  final IsolateFunction isolateFunction;

  IsolateManager({
    this.maxCocurrentIsolateCount = 3,
    this.reverseOrder = false,
    @required this.isolateFunction,
  }) : assert(maxCocurrentIsolateCount > 0 && isolateFunction != null);

  Future<dynamic> send(dynamic message) async {
    assert(message != null);
    Completer completer = Completer();
    _penddingActionList.add(_Action(message: message, completer: completer));
    handleNextAction();
    return completer.future;
  }

  ///执行下一个事件
  void handleNextAction({Isolate isolate, SendPort sendPort}) {
    if (_penddingActionList.isEmpty) {
      if (isolate != null) {
        isolate.kill(priority: Isolate.immediate);
      }
      return;
    }

    if (isolate != null && sendPort != null) {
      ///指定执行事件的isolate
      runNextAction(isolate, sendPort);
    } else if (_currentIsolateCount < maxCocurrentIsolateCount) {
      createIsolate();
    }
  }

  void runNextAction(Isolate isolate, SendPort sendPort) {
    assert(isolate != null && sendPort != null);
    if (isolate == null || sendPort == null) return;
    _Action action = reverseOrder == true ? _penddingActionList.removeLast() : _penddingActionList.removeAt(0);
    _processingActionList[isolate] = action;
    sendPort.send(_MessageInfo(function: isolateFunction, value: action.message));
  }

  Future<IsolateInfo> createIsolate() {
    assert(() {
      print('currentIsolateCount:$_currentIsolateCount');
      return true;
    }());

    ///新建Isolate
    _currentIsolateCount++;

    ReceivePort receivePort = ReceivePort();
    String debugName = DateTime.now().toIso8601String();
    return Isolate.spawn(
      _isolateMethod,
      receivePort.sendPort,
      errorsAreFatal: false,
      debugName: debugName,
    ).then((newIsolate) {
      if (newIsolate is Isolate) {
        assert(() {
          print('IsolateManager create isolate:${newIsolate.debugName}');
          return true;
        }());
        IsolateInfo isolateInfo = IsolateInfo(isolate: newIsolate);

        ///新建Isolate成功
        //设置error和exit监听
        ReceivePort errorPort = ReceivePort();
        ReceivePort exitPort = ReceivePort();
        newIsolate.addOnExitListener(exitPort.sendPort);
        newIsolate.addErrorListener(errorPort.sendPort);
        errorPort.listen((message) {
          assert(() {
            print('IsolateManager isolate error:${newIsolate.debugName}');
            return true;
          }());

          ///onError
          _processingActionList.remove(newIsolate)?.completer?.completeError(message);
          //执行下一个事件
          handleNextAction(isolate: newIsolate, sendPort: isolateInfo.sendPort);
        });
        exitPort.listen((message) {
          assert(() {
            //此时newIsolate.debugName获取的name为null
            print('isolate exit:$debugName');
            return true;
          }());

          ///onExit
          _currentIsolateCount--;
          receivePort?.close();
          handleNextAction();
        });
        
        receivePort.listen((message) {
          ///从isolate中传递过来的信息
          if (message is SendPort) {
            isolateInfo.sendPort = message;
            //执行下一个事件
            handleNextAction(isolate: newIsolate, sendPort: isolateInfo.sendPort);
          } else {
            _processingActionList.remove(newIsolate)?.completer?.complete(message);
            //执行下一个事件
            handleNextAction(isolate: newIsolate, sendPort: isolateInfo.sendPort);
          }
        });
        return isolateInfo;
      } else {
        ///新建Isolate失败
        _currentIsolateCount--;
        handleNextAction();
      }
    }).catchError((onError) {
      ///新建失败
      _currentIsolateCount--;
      handleNextAction();
    });
  }

  static void _isolateMethod(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((message) {
      ///从main isolate传递过来的信息
      if (message is _MessageInfo) {
        ///处理完消息后回传结果
        message.function(message.value).then((value) {
          sendPort.send(value);
        });
      }
    });
  }
}
