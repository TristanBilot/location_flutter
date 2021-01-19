import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'premium_nav_state.dart';

class PremiumNavCubit extends Cubit<PremiumNavState> {
  PremiumNavCubit() : super(PremiumNavCubitInitial());

  void goTo(int index) {
    emit(PremiumNavCubitIndexSwitched(index));
  }
}
