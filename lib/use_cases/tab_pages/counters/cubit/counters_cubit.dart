import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
import 'package:location_project/utils/toaster/types/chat_toaster.dart';
import 'package:location_project/utils/toaster/types/request_toaster.dart';
import 'package:location_project/utils/toaster/types/view_toaster.dart';

part 'counters_state.dart';

class CountersCubit extends Cubit<CountersState> {
  final MessagingDatabase _database;
  final BuildContext context;

  CountersCubit(this.context, this._database)
      : super(CountersInitial(Counter(0, 0, 0, 0, 0, 0)));

  Set<String> _previousChats;
  Set<String> _previousRequests;
  Set<String> _previousViews;

  void init() {
    final id = UserStore().user.id;
    final chatsStream = MessagingReposiory().getChats(id);
    final viewsStream = UserRepository().fetchViewsAsStream(id);

    /// Listens to new chats & requests.
    chatsStream.listen((chats) {
      final filteredChats = ChatsFilter().filter(chats, '');
      final filteredRequests = RequestFilter().filter(chats, '');
      int nbChats = filteredChats.length;
      int nbRequests = filteredRequests.length;
      int nbUnreadChats =
          filteredChats.where((chat) => chat.myActivitySeen == false).length;
      int nbUnreadRequests = filteredRequests
          .where((request) => request.myActivitySeen == false)
          .length;

      MessagingDatabase().put(nbChats: nbChats);
      MessagingDatabase().put(nbRequests: nbRequests);
      MessagingDatabase().put(nbUnreadChats: nbUnreadChats);
      MessagingDatabase().put(nbUnreadRequests: nbUnreadRequests);
      _emitCounters();

      _triggerChatToaster(filteredChats);
      _triggerRequestToaster(filteredRequests);
    });

    /// Listens to new views.
    viewsStream.listen((views) {
      int nbViews = views.length;
      int nbUnreadViews = views.where((view) => !view.isViewed).length;
      MessagingDatabase().put(nbViews: nbViews);
      MessagingDatabase().put(nbUnreadViews: nbUnreadViews);
      _emitCounters();

      _triggerViewToaster(views);
    });
  }

  void _emitCounters() {
    emit(CounterStoreState(Counter(
      _database.get(nbChats: true),
      _database.get(nbRequests: true),
      _database.get(nbViews: true),
      _database.get(nbUnreadChats: true),
      _database.get(nbUnreadRequests: true),
      _database.get(nbUnreadViews: true),
    )));
  }

  void _triggerChatToaster(List<Chat> filteredChats) {
    if (_previousChats != null)
      for (var chat in filteredChats)
        if (!_previousChats.contains(chat.chatID) &&
            MemoryStore().shouldDisplayChatToast &&
            UserStore().user.isChatNotifEnable &&
            !chat.iAmRequester)
          ChatToaster(context, chat, chat.otherParticipantID).show();
    Set<String> newChats = Set();
    filteredChats.forEach((chat) => newChats.add(chat.chatID));
    _previousChats = newChats;
  }

  void _triggerRequestToaster(List<Chat> filteredRequests) {
    if (_previousRequests != null)
      for (var chat in filteredRequests)
        if (!_previousRequests.contains(chat.chatID) &&
            MemoryStore().shouldDisplayRequestToast &&
            UserStore().user.isRequestNotifEnable &&
            !chat.iAmRequester)
          RequestToaster(context, chat, chat.otherParticipantID).show();
    Set<String> newRequests = Set();
    filteredRequests.forEach((req) => newRequests.add(req.chatID));
    _previousRequests = newRequests;
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
}
