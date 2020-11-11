import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import '../../../stores/extensions.dart';

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

class Chat implements FirestoreEntry {
  final List<String> userIDs;
  final List<String> userNames;
  final String chatID;
  final int lastActivityTime;
  final bool lastActivitySeen;
  bool isChatEngaged;
  final String requesterID;
  final String requestedID;

  @override
  bool get stringify => null;

  @override
  List<Object> get props => [
        userIDs,
        userNames,
        chatID,
        lastActivityTime,
        lastActivitySeen,
        isChatEngaged,
        requesterID,
        requestedID
      ];

  //   String id;
  // bool isEngaged;
  // bool lastActivitySeen;
  // double lastActivityTime;
  // String requestedID;
  // String requesterID;
  // String requestedName;
  // String requesterName;

  Chat(
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

  static Chat fromFirestoreObject(dynamic data) {
    return Chat(
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

  /// Prefer this method to build a chat entry instead of contstructor.
  /// `requesterID` is the requester and `requestedID` the
  /// requested user.
  static Chat newChatEntry(
    String requesterID,
    String requestedID,
    String requesterName,
    String requestedName,
    bool lastActivitySeen,
    bool isChatEngaged,
  ) {
    final chatID = MessagingReposiory.getChatID(requesterID, requestedID);
    final entry = Chat(
      [requesterID, requestedID],
      [requesterName, requestedName],
      chatID,
      FirestoreMessageEntry.Time,
      lastActivitySeen,
      isChatEngaged,
      requesterID,
      requestedID,
    );
    return entry;
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
