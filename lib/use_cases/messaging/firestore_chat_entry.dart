import 'package:location_project/models/firestore_entry.dart';
import '../../stores/extensions.dart';

enum ChatField {
  UserIDs,
  ChatID,
  LastActivityTime,
  LastActivitySeen,
}

class FirestoreChatEntry implements FirestoreEntry {
  final List<String> userIDs;
  final String chatID;
  final int lastActivityTime;
  final bool lastActivitySeen;

  FirestoreChatEntry(
    this.userIDs,
    this.chatID,
    this.lastActivityTime,
    this.lastActivitySeen,
  );

  dynamic toFirestoreObject() {
    return {
      ChatField.UserIDs.value: userIDs,
      ChatField.ChatID.value: chatID,
      ChatField.LastActivityTime.value: lastActivityTime,
      ChatField.LastActivitySeen.value: lastActivitySeen,
    };
  }

  static dynamic getCorrespondingUpdateObject(
      int lastActivityTime, bool lastActivitySeen) {
    if (lastActivityTime != null && lastActivitySeen != null)
      return {
        ChatField.LastActivityTime.value: lastActivityTime,
        ChatField.LastActivitySeen.value: lastActivitySeen
      };
    else if (lastActivityTime != null)
      return {ChatField.LastActivityTime.value: lastActivityTime};
    else if (lastActivitySeen != null)
      return {ChatField.LastActivitySeen.value: lastActivitySeen};
  }
}
