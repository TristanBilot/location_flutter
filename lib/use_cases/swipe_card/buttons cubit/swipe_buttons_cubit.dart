import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/request_sender.dart';

part 'swipe_buttons_state.dart';

class SwipeButtonsCubit extends Cubit<SwipeButtonsState> {
  SwipeButtonsCubit() : super(SwipeButtonsInitial());

  Future<void> like(User likedUser) async {
    await UserStore().addLike(likedUser.id);
    RequestSender().sendRequestTo(likedUser);
  }

  Future<void> unlike(User unlikedUser) async {
    await UserStore().addUnlike(unlikedUser.id);
  }

  void emitLike() {
    emit(SwipeButtonsLikeState());
  }

  void emitUnlike() {
    emit(SwipeButtonsUnlikeState());
  }
}