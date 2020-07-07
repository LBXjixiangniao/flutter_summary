import 'package:flutter/material.dart';
import 'package:flutter_summary/dart_class/mixn/dispose_listenable.dart';

abstract class StateDisposeNotificationsAbstract<T extends StatefulWidget> extends State<T> with DisposeListenable {
  @override
  void dispose() {
    notifyListeners();
    disposeDisposeListenable();
    super.dispose();
  }
}
