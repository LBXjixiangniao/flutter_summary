import 'dart:collection';

import 'package:flutter/foundation.dart';

class DisposeListener extends LinkedListEntry<DisposeListener> {
  VoidCallback _disposeCallBack;
  DisposeListener(VoidCallback dispose)
      : assert(dispose != null),
        _disposeCallBack = dispose;
  void cancel() {
    // list == null说明已经unlink了
    if (list != null) {
      unlink();
    }
  }

  @override
  LinkedList<DisposeListener> get list => super.list;

  ///禁止以下操作
  @override
  void insertAfter(DisposeListener entry) {}

  @override
  void insertBefore(DisposeListener entry) {}

  @override
  DisposeListener get next => null;

  @override
  DisposeListener get previous => null;
}

mixin ListenableDispose {
  LinkedList<DisposeListener> _listeners;

  void addDisposeListener(DisposeListener listener) {
    assert(listener != null);
    _listeners ??= LinkedList<DisposeListener>();
    _listeners.add(listener);
  }

  void notifyDisposeListeners() {
    if (_listeners != null) {
      final List<DisposeListener> localListeners =
          List<DisposeListener>.from(_listeners);
      for (DisposeListener listener in localListeners) {
        try {
          if (_listeners.contains(listener)) listener._disposeCallBack();
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'ListenableDispose',
            context: ErrorDescription(
                'while dispatching notifications for $runtimeType'),
            informationCollector: () sync* {
              yield DiagnosticsProperty<ListenableDispose>(
                'The $runtimeType sending notification was',
                this,
                style: DiagnosticsTreeStyle.errorProperty,
              );
            },
          ));
        }
      }
    }
  }
}
