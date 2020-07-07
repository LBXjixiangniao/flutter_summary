import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

mixin DisposeListenable {
  ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }

  @protected
  bool get hasListeners {
    assert(_debugAssertNotDisposed());
    return _listeners.isNotEmpty;
  }

  void addDisposeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  @mustCallSuper
  void disposeDisposeListenable() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  @protected
  @visibleForTesting
  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    if (_listeners != null) {
      final List<VoidCallback> localListeners = List<VoidCallback>.from(_listeners);
      for (final VoidCallback listener in localListeners) {
        try {
          if (_listeners.contains(listener)) listener();
        } catch (exception, stack) {
          FlutterError.reportError(FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'foundation library',
            context: ErrorDescription('while dispatching notifications for $runtimeType'),
            informationCollector: () sync* {
              yield DiagnosticsProperty<DisposeListenable>(
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
