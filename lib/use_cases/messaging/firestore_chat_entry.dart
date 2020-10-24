import 'package:location_project/models/firestore_entry.dart';
import '../../stores/extensions.dart';

enum ChatField {
  UserIDs,
  UserNames,
  ChatID,
  LastActivityTime,
  LastActivitySeen,
}

class FirestoreChatEntry implements FirestoreEntry {
  final List<String> userIDs;
  final List<String> userNames;
  final String chatID;
  final int lastActivityTime;
  final bool lastActivitySeen;

  FirestoreChatEntry(
    this.userIDs,
    this.userNames,
    this.chatID,
    this.lastActivityTime,
    this.lastActivitySeen,
  );

  dynamic toFirestoreObject() {
    return {
      ChatField.UserIDs.value: userIDs,
      ChatField.UserNames.value: userNames,
      ChatField.ChatID.value: chatID,
      ChatField.LastActivityTime.value: lastActivityTime,
      ChatField.LastActivitySeen.value: lastActivitySeen,
    };
  }

  static FirestoreChatEntry fromFirestoreObject(dynamic data) {
    return FirestoreChatEntry(
      List<String>.from(data[ChatField.UserIDs.value]),
      List<String>.from(data[ChatField.UserNames.value]),
      data[ChatField.ChatID.value] as String,
      data[ChatField.LastActivityTime.value] as int,
      data[ChatField.LastActivitySeen.value] as bool,
    );
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
    return null;
  }
}
