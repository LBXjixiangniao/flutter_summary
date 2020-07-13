import 'dart:async';

import 'package:flutter_summary/dart_class/abstract/bloc_abstract.dart';
import 'package:flutter_summary/dart_class/mixn/bloc_mixin.dart';
import 'package:flutter_summary/util/bind_state_callback.dart';
import 'package:meta/meta.dart';
part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends BlocCloseNotificationsAbstract<CounterEvent, CounterState> with BlocAddStateMixin {
  CounterBloc() : super(CounterInitial());

  ///模拟网络数据count
  int _count = 0;

  @override
  Stream<CounterState> mapEventToState(
    CounterEvent event,
  ) async* {
    if (event is GetCounterValueEvent) {
      getCounterValue(event);
    } else if (event is CounterSaveEvent) {
      _count = event.value;
      event.bindCallback?.call(true);
    }
  }

  void getCounterValue(GetCounterValueEvent event) {
    Future.delayed(Duration(seconds: 2), () {
      event?.bindCallback?.call(true);
      addState(CounterValueState(_count));
    });
  }

  void save(CounterSaveEvent event) {
    Future.delayed(Duration(seconds: 2), () {
      _count = event.value;
      event?.bindCallback?.call(true);
    });
  }
}
