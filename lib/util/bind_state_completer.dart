import 'dart:async';

import 'package:flutter/material.dart';

class BindStateCompleter<T> implements Completer<T> {
  final State bindState;
  Completer<T> _completer;

  BindStateCompleter(this.bindState) : assert(bindState != null) {
    _completer = Completer<T>();
  }
  BindStateCompleter.sync(this.bindState) : assert(bindState != null) {
    _completer = Completer<T>.sync();
  }

  @override
  void complete([FutureOr<T> value]) {
    if (bindState.mounted) {
      _completer.complete(value);
    }
  }

  @override
  void completeError(Object error, [StackTrace stackTrace]) {
    if (bindState.mounted) {
      _completer.completeError(error, stackTrace);
    }
  }

  @override
  Future<T> get future => _completer.future;

  @override
  bool get isCompleted => _completer.isCompleted;
}
