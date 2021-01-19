part of 'premium_nav_cubit.dart';

abstract class PremiumNavState extends Equatable {
  const PremiumNavState();

  @override
  List<Object> get props => [];
}

class PremiumNavCubitInitial extends PremiumNavState {}

class PremiumNavCubitIndexSwitched extends PremiumNavState {
  final int index;

  const PremiumNavCubitIndexSwitched(this.index);
  @override
  List<Object> get props => [index];
}
