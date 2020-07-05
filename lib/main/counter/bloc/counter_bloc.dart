import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_summary/dart_class/mixn/bloc_mixin.dart';
import 'package:flutter_summary/util/bind_state_callback.dart';
import 'package:meta/meta.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> with BlocAddStateMixin {
  CounterBloc() : super(CounterInitial());

  @override
  Stream<CounterState> mapEventToState(
    CounterEvent event,
  ) async* {
    if (event is GetCounterValueEvent) {
      getCounterValue(event);
    }
  }

  void getCounterValue(GetCounterValueEvent event) {
    Future.delayed(Duration(seconds: 2), () {
      event?.bindCallback?.callback?.call(true);
      addState(CounterValueState(0));
    });
  }
}
