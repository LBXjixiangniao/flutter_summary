part of 'counter_bloc.dart';

@immutable
abstract class CounterState {}

class CounterInitial extends CounterState {}

class CounterValueState extends CounterState {
  final int count;

  CounterValueState(this.count);
}

/************************** 页面间的state */

class CounterChangeState extends CounterState {}
