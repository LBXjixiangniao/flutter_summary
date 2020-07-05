import 'package:bloc/bloc.dart';

mixin BlocAddStateMixin<E, T> on Bloc<E, T> {
  void addState(T nextState) {
    Transition<E, T> transition = Transition<E, T>(
      currentState: state,
      event: null,
      nextState: nextState,
    );
    if (transition.nextState == state) return;
    try {
      onTransition(transition);
      // ignore: invalid_use_of_visible_for_testing_member
      emit(transition.nextState);
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }
}
