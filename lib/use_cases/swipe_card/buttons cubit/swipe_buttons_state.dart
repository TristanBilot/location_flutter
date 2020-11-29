part of 'swipe_buttons_cubit.dart';

abstract class SwipeButtonsState extends Equatable {
  const SwipeButtonsState();

  @override
  List<Object> get props => [];
}

class SwipeButtonsInitial extends SwipeButtonsState {}

class SwipeButtonsLikeState extends SwipeButtonsState {
  // all states should be distinct
  @override
  List<Object> get props => [Random().nextDouble() * 1000];
}

class SwipeButtonsUnlikeState extends SwipeButtonsState {
  @override
  List<Object> get props => [Random().nextDouble() * 1000];
}
