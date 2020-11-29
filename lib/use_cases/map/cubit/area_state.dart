part of 'area_cubit.dart';

abstract class AreaState extends Equatable {
  const AreaState();

  @override
  List<Object> get props => [];
}

class AreaInitial extends AreaState {}

class AreaFetchedState extends AreaState {
  const AreaFetchedState(this.users);
  final List<User> users;

  @override
  List<Object> get props => [];
}
