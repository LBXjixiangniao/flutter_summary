import 'package:flutter/material.dart';
import 'package:flutter_summary/util/order_task_manager.dart';
import 'package:flutter_summary/widgets/default_app_bar.dart';

class OrderTaskPage extends StatefulWidget {
  @override
  _OrderTaskPageState createState() => _OrderTaskPageState();
}

class _OrderTaskPageState extends State<OrderTaskPage> {
  final OrderedTaskManager _taskManager = OrderedTaskManager();

  @override
  void initState() {
    super.initState();
    _taskManager.addStepTask(
      StepTask(
        stepID: '1',
        stepFunction: ({finish, rerun, runNext}) {
          showDialog(
              context: context,
              barrierDismissible: false,
              child: Material(
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 200,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('步骤一'),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            finish();
                          },
                          child: Text('完成，不执行下一步'),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            rerun();
                          },
                          child: Text('失败了，重复执行这一步'),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            runNext();
                          },
                          child: Text('完成了，执行下一步'),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        },
      ),
    );
    _taskManager.addStepTask(
      StepTask(
        stepID: '2',
        stepFunction: ({finish, rerun, runNext}) {
          showDialog(
            context: context,
            barrierDismissible: false,
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('步骤二'),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          finish();
                        },
                        child: Text('完成，不执行下一步'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          rerun();
                        },
                        child: Text('失败了，重复执行这一步'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          runNext();
                        },
                        child: Text('完成了，执行下一步'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
    _taskManager.addStepTask(
      StepTask(
        stepID: '3',
        stepFunction: ({finish, rerun, runNext}) {
          showDialog(
            context: context,
            barrierDismissible: false,
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('步骤三'),
                      InkWell(
                        onTap: () {
                          finish();
                          Navigator.pop(context);
                          _taskManager.jumpToFirstStep();
                        },
                        child: Text('完成，跳回执行第一步'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          finish();
                        },
                        child: Text('完成，不执行下一步'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          rerun();
                        },
                        child: Text('失败了，重复执行这一步'),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          runNext();
                        },
                        child: Text('完成了，执行下一步'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        titleText: '小部件上loading',
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _taskManager.start();
              _taskManager.jumpToFirstStep();
            },
            child: Container(
              height: 40,
              alignment: Alignment.center,
              color: Colors.red,
              child: Text('开始执行'),
            ),
          ),
        ],
      ),
    );
  }
}
