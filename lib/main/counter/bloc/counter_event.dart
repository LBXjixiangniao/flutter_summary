part of 'counter_bloc.dart';

@immutable
abstract class CounterEvent {}

class GetCounterValueEvent extends CounterEvent {
  final BoolBindStateCallback bindCallback;

  GetCounterValueEvent(this.bindCallback);
}

class CounterSaveEvent extends CounterEvent {
  final int value;
  final BoolBindStateCallback bindCallback;

  CounterSaveEvent({this.bindCallback, this.value}) : assert(value != null);
}
