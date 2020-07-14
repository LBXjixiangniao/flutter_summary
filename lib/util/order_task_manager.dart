import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

/*
 * finish：表示该步骤执行完成了，但是不继续执行下一步
 * rerun：继续重复执行该步骤，实际执行的不一定是该步骤，可能执行了该步骤前面的步骤
 * runNext：执行_nextStepID标识的下一个步骤
 */
typedef void StepFunction({VoidCallback finish, VoidCallback rerun, VoidCallback runNext});

class StepTask extends LinkedListEntry<StepTask> {
  String stepID;

  ///如果返回true则自动执行下一步
  final StepFunction stepFunction;

  StepTask({this.stepID, @required this.stepFunction}) {
    assert(stepFunction != null);
    stepID ??= DateTime.now().toString();
  }
}

/*
 * 用于管理按顺序执行的一个逻辑的多个步骤，如mqtt的初始化、连接、订阅
 * 一个步骤执行结束后可以控制重复执行该步骤或者执行下一个步骤
 * 可以将执行步骤跳到前面的步骤，但是不能跳到后面
 */

class OrderedTaskManager {
  LinkedList<StepTask> _stepList = LinkedList<StepTask>();

  ///延时执行Timer
  bool _isStarted = false;
  bool _isRunning = false;
  String _nextStepID;

  ///检查id是否在_nextStepID之前，如果在_nextStepID之前，可以将_nextStepID定位到id处
  bool _setNextStepID(String id) {
    if (_nextStepID == null || _nextStepID == id) {
      _nextStepID = id;
      return true;
    }

    ///在stepList中，id对应的task在_nextStepID之前，设置才起效
    String tmpStr =
        _stepList.firstWhere((test) => test.stepID == _nextStepID || test.stepID == id, orElse: () => null)?.stepID;
    if (id == tmpStr) {
      _nextStepID = id;
      return true;
    }
    return false;
  }

  ///开始执行任务队列中的任务
  void start() {
    if (!_isStarted) {
      _isStarted = true;
      runNextStep();
    }
  }

  ///停止执行任务队列中的任务，如果有任务正在执行，则正在执行的任务不会停止
  void stop() {
    _isStarted = false;
  }

  ///添加任务到任务队列中
  void addStepTask(StepTask task) {
    if (task != null) {
      if (_stepList == null || _stepList.isEmpty) {
        _stepList ??= LinkedList<StepTask>();
        _nextStepID = task.stepID;
        _stepList.add(task);
      } else {
        StepTask checkResult = _stepList?.firstWhere((test) => test.stepID == task.stepID, orElse: () => null);
        if (checkResult == null) {
          ///不存在该task，所以添加到链表
          _stepList.add(task);
        }
      }
    }
  }

////跳转到任务队列中指定的id的任务处执行，只能执行_nextStepID前面的
  void jumpToStep(String stepID) {
    assert(stepID != null);
    _isStarted = true;
    if (_setNextStepID(stepID) && !_isRunning) {
      runNextStep();
    }
  }

  void jumpToFirstStep() {
    if (_stepList.isNotEmpty) {
      jumpToStep(_stepList.first.stepID);
    }
  }

  void runNextStep() {
    if (!_isStarted || _isRunning || _nextStepID == null || _stepList?.isNotEmpty != true) {
      return;
    }

    _isRunning = true;
    StepTask stepToRun;
    if (_stepList.isNotEmpty) {
      stepToRun = _stepList.firstWhere((test) => test.stepID == _nextStepID, orElse: () => null);
    }

    if (stepToRun?.next != null) {
      _nextStepID = stepToRun.next.stepID;
    } else {
      _nextStepID = null;
    }

    if (stepToRun?.stepFunction != null) {
      stepToRun.stepFunction(
        finish: () {
          _isRunning = false;
        },
        rerun: () {
          _isRunning = false;
          _setNextStepID(stepToRun.stepID);

          ///设置成功或者失败都继续执行
          Timer.run(() {
            runNextStep();
          });
        },
        runNext: () {
          _isRunning = false;
          Timer.run(() {
            runNextStep();
          });
        },
      );
    } else {
      _isRunning = false;
    }
  }
}
