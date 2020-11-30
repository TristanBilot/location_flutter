part of 'navigation_cubit.dart';

abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object> get props => [];
}

class NavigationInitial extends NavigationState {}

class NavigateToIndexState extends NavigationState {
  final int index;
  const NavigateToIndexState(this.index);

  @override
  List<Object> get props => [Random().nextDouble() * 1000];
}
