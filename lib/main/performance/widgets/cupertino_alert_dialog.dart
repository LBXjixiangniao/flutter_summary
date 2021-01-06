import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoAlertDialogTest extends StatelessWidget {
  void showIOSDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('CupertinoAlertDialog'),
          content: Text('弹框会off screen layer'),
        );
      },
    );
  }

  void showAndroidDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: Text('AlertDialog'),
          content: Text('弹框不会off screen layer'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AlertDialog测试'),
      ),
      body: Column(
        children: [
          FlatButton(
            onPressed: () {
              showIOSDialog(context);
            },
            child: Text('CupertinoAlertDialog'),
          ),
          FlatButton(
            onPressed: () {
              showAndroidDialog(context);
            },
            child: Text('AlertDialog'),
          ),
        ],
      ),
    );
  }
}
