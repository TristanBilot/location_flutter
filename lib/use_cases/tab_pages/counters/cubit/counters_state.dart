part of 'counters_cubit.dart';

abstract class CountersState extends Equatable {
  final Counter counter;
  const CountersState(this.counter);

  @override
  List<Object> get props => [];
}

class CountersInitial extends CountersState {
  final Counter counter;
  CountersInitial(this.counter) : super(counter);
  @override
  List<Object> get props => [counter];
}

class CounterStoreState extends CountersState {
  final Counter counter;
  CounterStoreState(this.counter) : super(counter);
  @override
  List<Object> get props => [counter];
}
