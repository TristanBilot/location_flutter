import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counter.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/request_filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

part 'counters_state.dart';

class CountersCubit extends Cubit<CountersState> {
  CountersCubit(this._database)
      : super(CountersInitial(Counter(0, 0, 0, 0, 0, 0)));

  MessagingDatabase _database;

  void init() {
    final id = UserStore().user.id;
    final chatsStream = MessagingReposiory().getChats(id);
    final viewsStream = UserRepository()
        .getCollectionListOfIDs(id, UserField.UserIDsWhoWiewedMe);

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
    });

    viewsStream.listen((views) {
      int nbViews = views.length;
      MessagingDatabase().put(nbViews: nbViews);
      _emitCounters();
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
}
