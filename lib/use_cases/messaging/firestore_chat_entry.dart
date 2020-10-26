import 'package:location_project/models/firestore_entry.dart';
import '../../stores/extensions.dart';

enum ChatField {
  UserIDs,
  UserNames,
  ChatID,
  LastActivityTime,
  LastActivitySeen,

  IsChatEngaged,
  RequesterID,
  RequestedID,
}

class FirestoreChatEntry implements FirestoreEntry {
  final List<String> userIDs;
  final List<String> userNames;
  final String chatID;
  final int lastActivityTime;
  final bool lastActivitySeen;
  final bool isChatEngaged;
  final String requesterID;
  final String requestedID;

  FirestoreChatEntry(
    this.userIDs,
    this.userNames,
    this.chatID,
    this.lastActivityTime,
    this.lastActivitySeen,
    this.isChatEngaged,
    this.requesterID,
    this.requestedID,
  );

  dynamic toFirestoreObject() {
    return {
      ChatField.UserIDs.value: userIDs,
      ChatField.UserNames.value: userNames,
      ChatField.ChatID.value: chatID,
      ChatField.LastActivityTime.value: lastActivityTime,
      ChatField.LastActivitySeen.value: lastActivitySeen,
      ChatField.IsChatEngaged.value: isChatEngaged,
      ChatField.RequesterID.value: requesterID,
      ChatField.RequestedID.value: requestedID,
    };
  }

  static FirestoreChatEntry fromFirestoreObject(dynamic data) {
    return FirestoreChatEntry(
      List<String>.from(data[ChatField.UserIDs.value]),
      List<String>.from(data[ChatField.UserNames.value]),
      data[ChatField.ChatID.value] as String,
      data[ChatField.LastActivityTime.value] as int,
      data[ChatField.LastActivitySeen.value] as bool,
      data[ChatField.IsChatEngaged.value] as bool,
      data[ChatField.RequesterID.value] as String,
      data[ChatField.RequestedID.value] as String,
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
