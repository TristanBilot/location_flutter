import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/request_sender.dart';

part 'swipe_buttons_state.dart';

class SwipeButtonsCubit extends Cubit<SwipeButtonsState> {
  SwipeButtonsCubit() : super(SwipeButtonsInitial());

  Future<void> like(User likedUser, BuildContext context) async {
    // Match
    if (MemoryStore().containsUserWhoLikedMe(likedUser.id)) {
      await UserStore().addLike(likedUser.id);
      await UserRepository().deleteCollectionSnapshot(
          UserStore().user.id, UserField.UsersWhoLikedMe, likedUser.id);
      await RequestSender().sendRequestTo(likedUser);
      print('--- Match');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: Theme.of(context).backgroundColor.withAlpha(100),
              title: Text("hey")));
    } else {
      print('--- Like but no Match');
      // Not a match (yet)
      await UserStore().addLike(likedUser.id);
    }
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
