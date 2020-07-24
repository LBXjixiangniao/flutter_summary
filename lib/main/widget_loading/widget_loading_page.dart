import 'package:flutter/material.dart';
import 'package:flutter_summary/widgets/default_app_bar.dart';
import 'package:flutter_summary/widgets/widget_loading_builder.dart';

class WidgetLoading extends StatefulWidget {
  @override
  _WidgetLoadingState createState() => _WidgetLoadingState();
}

class _WidgetLoadingState extends State<WidgetLoading> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        titleText: '小部件上loading',
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          WidgetLoadingBuilder(
            height: 80,
            loading: _isLoading,
            timeoutDuration: Duration(seconds: 3),
            loadingbuilder: (context) => CircleDotsLoadingWidget(color: Colors.red,size: 40,),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLoading = true;
                });
              },
              child: Container(
                height: 40,
                alignment: Alignment.center,
                color: Colors.red,
                child: Text('点击loading'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
