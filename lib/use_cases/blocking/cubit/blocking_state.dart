part of 'blocking_cubit.dart';

abstract class BlockingState extends Equatable {
  const BlockingState();

  @override
  List<Object> get props => [];
}

class BlockingInitial extends BlockingState {}

class BlockingUsersFetchedState extends BlockingState {
  @override
  List<Object> get props => [];
}
