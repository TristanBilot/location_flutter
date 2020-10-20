import 'package:location_project/models/firestore_entry.dart';
import '../../stores/extensions.dart';

enum ChatField {
  UserIDs,
  ChatID,
}

class FirestoreChatEntry implements FirestoreEntry {
  final List<String> userIDs;
  final String chatID;

  FirestoreChatEntry(
    this.userIDs,
    this.chatID,
  );

  dynamic toFirestoreObject() {
    return {
      ChatField.UserIDs.value: userIDs,
      ChatField.ChatID.value: chatID,
    };
  }
}
