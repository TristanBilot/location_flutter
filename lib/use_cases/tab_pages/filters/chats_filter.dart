import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/filters/filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';

class ChatsFilter extends ChatFilter {
  List<Chat> filter(List<Chat> chats, String pattern) {
    return _sortChatsByMostRecent(_filterChatsByName(chats, pattern))
        .where((chat) => chat.isChatEngaged)
        .toList();
  }

  List<Chat> _sortChatsByMostRecent(List<Chat> chats) {
    return chats
      ..sort((a, b) => b.lastActivityTime.compareTo(a.lastActivityTime));
  }

  List<Chat> _filterChatsByName(List<Chat> chats, String pattern) {
    if (pattern.length == 0) return chats;
    return chats.where((chat) {
      final otherParticipantName = (chat.userNames
            ..removeWhere((userName) => userName == UserStore().user.firstName))
          .first;
      return otherParticipantName.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }
}
