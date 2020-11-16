import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

class MessageSender {
  /// Create a new message in `chatID` with `message` content.
  /// The message is sent by the `logged user` at the `current time`
  /// and the last activity is update.
  Future<void> send(String message, Chat chat) async {
    final sendBy = UserStore().user.id;
    final time = Message.Time;
    final entry = Message(message, sendBy, time);

    MessagingReposiory().newMessage(chat.chatID, entry);
    MessagingReposiory().updateChatLastActivity(chat,
        lastActivityTime: time,
        lastActivitySeen: true,
        lastActivitySeenParticipant: Participant.Me);
    MessagingReposiory().updateChatLastActivity(chat,
        lastActivityTime: time,
        lastActivitySeen: false,
        lastActivitySeenParticipant: Participant.Other);
  }
}
