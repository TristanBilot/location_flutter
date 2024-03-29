import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:location_project/controllers/app_badge_controller.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/usersFromIDsFetcher.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counter.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/request_filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/utils/toaster/types/like_toaster.dart';
import 'package:location_project/utils/toaster/types/new_match_toaster.dart';
import 'package:location_project/utils/toaster/types/view_toaster.dart';

part 'counters_state.dart';

class CountersCubit extends Cubit<CountersState> {
  final MessagingDatabase _database;
  final BuildContext context;

  CountersCubit(
    this.context,
    this._database,
  ) : super(CountersInitial(Counter(0, 0, 0, 0, 0, 0, 0)));

  Set<String> _previousChats;
  Set<String> _previousViews;
  Set<String> _previousLikes;

  void init() {
    final id = UserStore().user.id;
    final chatsStream = MessagingReposiory().getChats(id);
    final viewsStream = UserRepository().fetchViewsAsStream(id);
    final likesStream =
        UserRepository().getCollectionListOfIDs(id, UserField.UsersWhoLikedMe);

    /// Listens to new chats.
    chatsStream.listen((chats) {
      final filteredMatches = ChatsFilter().filter(chats, '');
      final filteredNewMatches = NewMatchFilter().filter(chats, '');
      int nbMatches = filteredMatches.length;
      int nbNewMatches = filteredNewMatches.length;
      int nbUnreadChats =
          filteredMatches.where((chat) => chat.myActivitySeen == false).length;

      _database.put(nbMatches: nbMatches);
      _database.put(nbNewMatches: nbNewMatches);
      _database.put(nbUnreadChats: nbUnreadChats);

      _triggerNewMatchToaster(filteredNewMatches);

      _emitCounters();
    });

    /// Listens to new views.
    viewsStream.listen((views) async {
      int nbViews = views.length;
      int nbNewViews = views.where((view) => !view.isViewed).length;

      _database.put(nbViews: nbViews);
      _database.put(nbNewViews: nbNewViews);

      final ids = views.map((e) => e.id).toList();
      final users = await UsersFromIDsFetcher().fetch(ids);
      users.forEach((e) => MemoryStore().putUser(e));

      _triggerViewToaster(views);

      emit(NewViewsState(users));
      _emitCounters();
    });

    /// Listens to new incoming likes.
    likesStream.listen((likes) async {
      int nbLikes = likes.length;
      int nbNewLikes = _previousLikes == null
          ? nbLikes
          : likes.where((like) => !_previousLikes.contains(like)).length;

      _database.put(nbLikes: nbLikes);
      _database.put(nbNewLikes: nbNewLikes);

      final users = await UsersFromIDsFetcher().fetch(likes);
      users.forEach((e) => MemoryStore().putUser(e));

      _triggerLikeToaster(likes);

      emit(NewLikesState(users));
      _emitCounters();
    });
  }

  void _emitCounters() {
    emit(CounterStoreState(
      Counter(
        _database.get(nbMatches: true),
        _database.get(nbNewMatches: true),
        _database.get(nbUnreadChats: true),
        _database.get(nbViews: true),
        _database.get(nbNewViews: true),
        _database.get(nbLikes: true),
        _database.get(nbNewLikes: true),
      ),
    ));
    AppBadgeController().updateAppBadge();
  }

  void _triggerNewMatchToaster(List<Chat> filteredNewMatches) {
    if (_previousChats != null)
      for (var chat in filteredNewMatches)
        if (!_previousChats.contains(chat.chatID) &&
            MemoryStore().shouldDisplayRequestToast &&
            UserStore().user.isRequestNotifEnable &&
            !chat.iAmRequester)
          NewMatchToaster(context, chat, chat.otherParticipantID).show();
    Set<String> newRequests = Set();
    filteredNewMatches.forEach((req) => newRequests.add(req.chatID));
    _previousChats = newRequests;
  }

  void _triggerViewToaster(List<View> views) {
    if (_previousViews != null)
      for (var view in views)
        if (!_previousViews.contains(view.id) &&
            MemoryStore().shouldDisplayViewToast &&
            UserStore().user.isViewNotifEnable)
          ViewToaster(context, view.id).show();
    Set<String> newViews = Set();
    views.forEach((view) => newViews.add(view.id));
    _previousViews = newViews;
  }

  void _triggerLikeToaster(List<String> likeIDs) {
    if (_previousLikes != null)
      for (var like in likeIDs)
        if (!_previousLikes.contains(like) &&
            MemoryStore().shouldDisplayViewToast &&
            UserStore().user.isViewNotifEnable)
          LikeToaster(context, like).show();
    Set<String> newLikes = Set();
    likeIDs.forEach((like) => newLikes.add(like));
    _previousLikes = newLikes;
  }
}
