import 'package:flutter/material.dart';
import '../abstract/listenable_dispose.dart';

mixin StateDisposeNotifierMixin<T extends StatefulWidget> on State<T>, ListenableDispose {
  void dispose() {
    notifyDisposeListeners();
    super.dispose();
  }
}
