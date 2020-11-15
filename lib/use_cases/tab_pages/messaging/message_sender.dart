import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

class MessageSender {
  /// Create a new message in `chatID` with `message` content.
  /// The message is sent by the `logged user` at the `current time`
  /// and the last activity is update.
  Future<void> send(String message, String chatID) async {
    final sendBy = UserStore().user.id;
    final time = Message.Time;
    final entry = Message(message, sendBy, time);

    MessagingReposiory().newMessage(chatID, entry);
    MessagingReposiory().updateChatLastActivity(
      chatID,
      lastActivityTime: time,
      lastActivitySeen: false,
    );
  }
}
