import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/usersFromIDsFetcher.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';

part 'swipe_state.dart';

class SwipeCubit extends Cubit<SwipeState> {
  SwipeCubit() : super(SwipeInitial());

  static const RangeToFetch = 5;

  List<String> _likedUsers = List();
  List<String> _unlikedUsers = List();
  List<String> _usersWhoLikedMe = List();
  List<String> _areaUsers = List();

  Future fetchUsersFeed() async {
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
      MemoryStore().putUsersWhoLikedMe(userIDs.toSet());
      _fetchUsersData();
    });
  }

// TODO: ATTENTION A MODIFIER CAR FAUX
  void _fetchUsersData() {
    List<String> allUsers = []
      ..addAll(_likedUsers)
      ..addAll(_unlikedUsers)
      ..addAll(_usersWhoLikedMe)
      ..addAll(_areaUsers);
    _fetchUsersRangeFromIDs(allUsers, 0);
  }

  Future _fetchUsersRangeFromIDs(List<String> allUsers, int atIndex) async {
    if (allUsers.length <= atIndex) {
      throw ('Invalid index at _fetchUsersRangeFromIDs()');
    }
    final sublist = _getUserSublistToFetch(allUsers, atIndex);
    final users = await UsersFromIDsFetcher().fetch(sublist);

    users.forEach((e) => MemoryStore().putUser(e));
    emit(SwipableUsersFetched(users));
  }

  List<String> _getUserSublistToFetch(List<String> allUsers, int atIndex) {
    int endIndex = atIndex +
        (RangeToFetch > allUsers.length - atIndex
            ? allUsers.length - atIndex
            : RangeToFetch);
    return allUsers.sublist(atIndex, endIndex);
  }
}
