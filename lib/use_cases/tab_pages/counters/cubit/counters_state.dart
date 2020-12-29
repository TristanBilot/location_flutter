part of 'counters_cubit.dart';

abstract class CountersState extends Equatable {
  @override
  List<Object> get props => [];
}

class CountersInitial extends CountersState {
  final Counter counter;
  CountersInitial(this.counter);
  @override
  List<Object> get props => [counter];
}

class CounterStoreState extends CountersState {
  final Counter counter;
  CounterStoreState(this.counter);
  @override
  List<Object> get props => [counter];

  bool isANotificationUnread() {
    return counter.nbUnreadChats != 0 ||
        counter.nbNewMatches != 0 ||
        counter.nbNewViews != 0 ||
        counter.nbNewLikes != 0;
  }
}

class NewLikesState extends CountersState {
  final List<User> likes;
  NewLikesState(this.likes);
  @override
  List<Object> get props => [likes];
}
