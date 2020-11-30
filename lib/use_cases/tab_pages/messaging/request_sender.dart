import 'package:location_project/models/user.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';

class RequestSender {
  Future<void> sendRequestTo(User likedUser) async {
    final user = UserStore().user;
    final entry = Chat.newChatEntry(
      user.id,
      likedUser.id,
      user.firstName,
      likedUser.firstName,
      true,
      false,
      false,
    );
    MessagingReposiory().newChat(entry.chatID, entry);
  }
}
