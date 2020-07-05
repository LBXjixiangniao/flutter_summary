import 'package:flutter/material.dart';

class BindStateCallback<T> {
  final State state;
  final ValueChanged<T> callback;

  BindStateCallback({this.state, this.callback});
}

class BoolBindStateCallback extends BindStateCallback<bool> {
  BoolBindStateCallback({State<StatefulWidget> state, ValueChanged<bool> callback})
      : super(
          state: state,
          callback: callback,
        );
}
