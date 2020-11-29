part of 'swipe_cubit.dart';

abstract class SwipeState extends Equatable {
  const SwipeState();

  @override
  List<Object> get props => [];
}

class SwipeInitial extends SwipeState {}

class SwipableUsersFetched extends SwipeState {
  final List<String> users;
  const SwipableUsersFetched(this.users);

  @override
  List<Object> get props => [];
}
