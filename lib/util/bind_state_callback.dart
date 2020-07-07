import 'package:flutter/material.dart';

class BindStateCallback<T> {
  final State state;
  final ValueChanged<T> _callback;

  BindStateCallback({@required this.state, @required ValueChanged<T> callback})
      : assert(state != null && callback != null),
        _callback = callback;

  void call(T value) {
    if (state?.mounted == true && _callback != null) {
      _callback(value);
    }
  }
}

class BoolBindStateCallback extends BindStateCallback<bool> {
  BoolBindStateCallback({State<StatefulWidget> state, ValueChanged<bool> callback})
      : super(
          state: state,
          callback: callback,
        );
}
