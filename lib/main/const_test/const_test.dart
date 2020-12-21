import 'dart:math';

import 'package:flutter/material.dart';

class ConstWidgetTest extends StatefulWidget {
  @override
  _ConstWidgetTestState createState() => _ConstWidgetTestState();
}

class _ConstWidgetTestState extends State<ConstWidgetTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('const修饰widget效果测试'),
      ),
      body: Column(
        children: [
          const ConstWidget(),
          NotConstWidget(),
          FlatButton(
            onPressed: () {
              setState(() {});
            },
            child: Text('setState'),
          ),
        ],
      ),
    );
  }
}

class ConstWidget extends StatelessWidget {
  const ConstWidget();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: BoxConstraints.expand().maxWidth,
      color: Colors.red,
      alignment: Alignment.center,
      child: Text(Random().nextInt(200).toString()),
    );
  }
}

class NotConstWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: BoxConstraints.expand().maxWidth,
      alignment: Alignment.center,
      color: Colors.yellow,
      child: Text(Random().nextInt(200).toString()),
    );
  }
}
