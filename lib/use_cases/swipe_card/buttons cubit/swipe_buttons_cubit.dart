import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'swipe_buttons_state.dart';

class SwipeButtonsCubit extends Cubit<SwipeButtonsState> {
  SwipeButtonsCubit() : super(SwipeButtonsInitial());

  void like() {
    emit(SwipeButtonsLikeState());
  }

  void unlike() {
    emit(SwipeButtonsUnlikeState());
  }
}
