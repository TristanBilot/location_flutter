part of 'blocking_cubit.dart';

abstract class BlockingState extends Equatable {
  const BlockingState();

  @override
  List<Object> get props => [];
}

class BlockingInitial extends BlockingState {}

class BlockingUsersFetched extends BlockingState {
  @override
  List<Object> get props => [];
}
