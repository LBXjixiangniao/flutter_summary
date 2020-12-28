import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';

class FlutterBoostFirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            FlutterBoost.singleton.close('FlutterBoostFirstPage');
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('flutter'),
      ),
      body: Center(
        child: Text('flutter_boost第一个flutter页面'),
      ),
    );
  }
}
