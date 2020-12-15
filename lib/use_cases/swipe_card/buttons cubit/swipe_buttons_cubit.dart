import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/new_match_dialog.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/request_sender.dart';

part 'swipe_buttons_state.dart';

class SwipeButtonsCubit extends Cubit<SwipeButtonsState> {
  SwipeButtonsCubit() : super(SwipeButtonsInitial());

  Future<void> like(User likedUser, BuildContext context) async {
    // Match
    if (MemoryStore().containsUserWhoLikedMe(likedUser.id)) {
      final id = UserStore().user.id;
      await UserStore().addLike(likedUser.id);
      await UserRepository().deleteCollectionSnapshot(
          id, UserField.UsersWhoLikedMe, likedUser.id);
      await RequestSender().sendRequestTo(likedUser);
      final chat = await MessagingReposiory()
          .getChatAsChat(MessagingReposiory.getChatID(id, likedUser.id));
      _showNewMatchDialog(context, likedUser, chat);
      print('--- Match');
    } else {
      print('--- Like but no Match');
      // Not a match (yet)
      await UserStore().addLike(likedUser.id);
    }
  }

  Future<void> unlike(User unlikedUser) async {
    await UserStore().addUnlike(unlikedUser.id);
  }

  void emitLike() => emit(SwipeButtonsLikeState());

  void emitUnlike() => emit(SwipeButtonsUnlikeState());

  void _showNewMatchDialog(BuildContext context, User matchedUser, Chat chat) {
    showDialog(
      context: context,
      builder: (context) => NewMatchDialog(
        matchedUser,
        chat,
      ),
    );
  }
}
