import 'dart:async';

class QueueTaskManager {
  Future _future;
  Completer _currentTaskCompleter;

  void addTask(void Function(Completer completer) task) {
    if (_future == null) {
      _future = Future.value(true);
    }
    Completer _complete = Completer();
    _future.then((value) {
      _currentTaskCompleter = _complete;
      task(_complete);
    });
    _future = _complete.future;
  }

  void dispose() {
    if (_currentTaskCompleter != null && !_currentTaskCompleter.isCompleted) {
      _currentTaskCompleter.completeError('error');
    }
    _currentTaskCompleter = null;
    _future = null;
  }
}
