import 'package:bloc/bloc.dart';
import 'package:flutter_summary/dart_class/mixin/dispose_notifier.dart';

class DisposeNotifierBloc<E, T> extends Bloc<E, T> with DisposeNotifier {
  DisposeNotifierBloc(T initialState) : super(initialState);

  Future<void> close() {
    notifyDisposeListeners();
    return super.close();
  }

  @override
  Stream<T> mapEventToState(E event) {
    // TODO: implement mapEventToState
    throw UnimplementedError();
  }
}
