/**
 * 复制ChangeNotifier修改
 */
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class _ListenerEntry extends LinkedListEntry<_ListenerEntry> {
  _ListenerEntry(this.listener);
  final VoidCallback listener;
}

mixin DisposeNotifier {
  LinkedList<_ListenerEntry> _listeners = LinkedList<_ListenerEntry>();

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw FlutterError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.'
        );
      }
      return true;
    }());
    return true;
  }

  bool get hasDisposeListeners {
    assert(_debugAssertNotDisposed());
    return _listeners.isNotEmpty;
  }

  void addDisposeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(_ListenerEntry(listener));
  }

  void removeDisposeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    for (final _ListenerEntry entry in _listeners) {
      if (entry.listener == listener) {
        entry.unlink();
        return;
      }
    }
  }

  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have changed. Listeners that are added during this iteration
  /// will not be visited. Listeners that are removed during this iteration will
  /// not be visited after they are removed.
  ///
  /// Exceptions thrown by listeners will be caught and reported using
  /// [FlutterError.reportError].
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (i.e.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removeListener].
  @protected
  @visibleForTesting
  void notifyDisposeListeners() {
    assert(_debugAssertNotDisposed());
    if (_listeners.isEmpty)
      return;

    final List<_ListenerEntry> localListeners = List<_ListenerEntry>.from(_listeners);

    for (final _ListenerEntry entry in localListeners) {
      try {
        if (entry.list != null)
          entry.listener();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'foundation library',
          context: ErrorDescription('while dispatching notifications for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<DisposeNotifier>(
              'The $runtimeType sending notification was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
    _listeners = null;
  }
}