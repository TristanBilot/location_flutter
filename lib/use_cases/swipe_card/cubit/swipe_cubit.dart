import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';

part 'swipe_state.dart';

class SwipeCubit extends Cubit<SwipeState> {
  SwipeCubit() : super(SwipeInitial());

  List<String> _likedUsers = List();
  List<String> _unlikedUsers = List();
  List<String> _usersWhoLikedMe = List();
  List<String> _areaUsers = List();

  Future fetchSwipableUsers() async {
    _likedUsers = UserStore().user.likedUsers;
    _unlikedUsers = UserStore().user.unlikedUsers;
    _areaUsers = MemoryStore().users.map((e) => e.id).toList();
    _listenUsersWhoLikedMe();
  }

  void _listenUsersWhoLikedMe() {
    final stream = UserRepository().getCollectionListOfIDs(
      UserStore().user.id,
      UserField.UsersWhoLikedMe,
    );
    stream.listen((userIDs) {
      _usersWhoLikedMe = userIDs;
      _emitAllUsers();
    });
  }

  void _emitAllUsers() {
    List<String> allUsers = []
      ..addAll(_likedUsers)
      ..addAll(_unlikedUsers)
      ..addAll(_usersWhoLikedMe)
      ..addAll(_areaUsers);
    emit(SwipableUsersFetched(allUsers));
  }
}
