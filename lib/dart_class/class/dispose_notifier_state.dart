import 'package:flutter/material.dart';
import 'package:flutter_summary/dart_class/mixin/dispose_notifier.dart';

class DisposeNotifierState<T extends StatefulWidget> extends State<T> with DisposeNotifier {
  @override
  void dispose() {
    notifyDisposeListeners();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}