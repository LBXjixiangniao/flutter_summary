import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_summary/widgets/hit_test_manager_widget.dart';

class HitTestManager extends StatefulWidget {
  @override
  _HitTestManagerState createState() => _HitTestManagerState();
}

class _HitTestManagerState extends State<HitTestManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HitTestCheckWidget(
              child: GestureDetector(
                onTap: () => print('bottom'),
                child: Container(
                  width: 300,
                  height: 300,
                  color: Colors.green,
                ),
              ),
              checkHitTestPermission: (_) => true,
            ),
            HitTestIgnoreManagerWidget(
              ignoreHitTest: true,
              ignoreWidgetBuilder: (child) => GestureDetector(
                onTap: () {
                  print('tap one');
                },
                child: Container(
                  color: Colors.yellow,
                  width: 300,
                  height: 200,
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
              hitestChild: GestureDetector(
                onTap: () {
                  print('tap two');
                },
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     setState(() {});
            //   },
            //   child: Container(
            //     width: 100,
            //     height: 100,
            //     color: Colors.blue,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
