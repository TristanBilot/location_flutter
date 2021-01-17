part of 'counters_cubit.dart';

abstract class CountersState extends Equatable {
  final List myProps;
  CountersState(this.myProps);
  @override
  List<Object> get props => myProps;
}

class CountersInitial extends CountersState {
  final Counter counter;
  CountersInitial(this.counter) : super([counter]);
  @override
  List<Object> get props => [counter];
}

class CounterStoreState extends CountersState {
  final Counter counter;
  CounterStoreState(this.counter) : super([counter]);
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
  NewLikesState(this.likes) : super([likes]);
  @override
  List<Object> get props => [likes];
}

class NewViewsState extends CountersState {
  final List<User> views;
  NewViewsState(this.views) : super([views]);
  @override
  List<Object> get props => [views];
}
