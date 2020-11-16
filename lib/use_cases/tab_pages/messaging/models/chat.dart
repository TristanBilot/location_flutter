import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import '../../../../stores/extensions.dart';

enum ChatField {
  UserIDs,
  UserNames,
  ChatID,
  LastActivityTime,
  RequesterLastActivitySeen,
  RequestedLastActivitySeen,

  IsChatEngaged,
}

/// Represents the 2 participants of a chat:
/// Me is the logged usern other is the other one.
enum Participant {
  Me,
  Other,
}

class Chat implements FirestoreEntry {
  final List<String> userIDs;
  final List<String> userNames;
  final String chatID;
  final int lastActivityTime;
  final bool requesterLastActivitySeen;
  final bool requestedLastActivitySeen;
  bool isChatEngaged;
  final String requesterID; // userIDs[0]
  final String requestedID; // userIDs[1]

  @override
  bool get stringify => null;

  @override
  List<Object> get props => [
        userIDs,
        userNames,
        chatID,
        lastActivityTime,
        requesterLastActivitySeen,
        requestedLastActivitySeen,
        isChatEngaged,
        requesterID,
        requestedID
      ];

  Chat(
    this.userIDs,
    this.userNames,
    this.chatID,
    this.lastActivityTime,
    this.requesterLastActivitySeen,
    this.requestedLastActivitySeen,
    this.isChatEngaged,
  )   : this.requesterID = userIDs[0],
        this.requestedID = userIDs[1];

  bool get iAmRequester => UserStore().user.id == requesterID;

  bool get myActivitySeen =>
      iAmRequester ? requesterLastActivitySeen : requestedLastActivitySeen;

  dynamic toFirestoreObject() {
    return {
      ChatField.UserIDs.value: userIDs,
      ChatField.UserNames.value: userNames,
      ChatField.ChatID.value: chatID,
      ChatField.LastActivityTime.value: lastActivityTime,
      ChatField.RequesterLastActivitySeen.value: requesterLastActivitySeen,
      ChatField.RequestedLastActivitySeen.value: requestedLastActivitySeen,
      ChatField.IsChatEngaged.value: isChatEngaged,
    };
  }

  static Chat fromFirestoreObject(dynamic data) {
    return Chat(
      List<String>.from(data[ChatField.UserIDs.value]),
      List<String>.from(data[ChatField.UserNames.value]),
      data[ChatField.ChatID.value] as String,
      data[ChatField.LastActivityTime.value] as int,
      data[ChatField.RequesterLastActivitySeen.value] as bool,
      data[ChatField.RequestedLastActivitySeen.value] as bool,
      data[ChatField.IsChatEngaged.value] as bool,
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
    bool requesterLastActivitySeen,
    bool requestedLastActivitySeen,
    bool isChatEngaged,
  ) {
    final chatID = MessagingReposiory.getChatID(requesterID, requestedID);
    final entry = Chat(
      [requesterID, requestedID],
      [requesterName, requestedName],
      chatID,
      Message.Time,
      requesterLastActivitySeen,
      requestedLastActivitySeen,
      isChatEngaged,
    );
    return entry;
  }

  static dynamic getCorrespondingUpdateObject({
    int lastActivityTime,
    bool requesterLastActivitySeen,
    bool requestedLastActivitySeen,
  }) {
    if (lastActivityTime != null &&
        requesterLastActivitySeen != null &&
        requestedLastActivitySeen != null)
      return {
        ChatField.LastActivityTime.value: lastActivityTime,
        ChatField.RequesterLastActivitySeen.value: requesterLastActivitySeen,
        ChatField.RequestedLastActivitySeen.value: requestedLastActivitySeen
      };
    else if (lastActivityTime != null && requesterLastActivitySeen != null)
      return {
        ChatField.LastActivityTime.value: lastActivityTime,
        ChatField.RequesterLastActivitySeen.value: requesterLastActivitySeen,
      };
    else if (lastActivityTime != null && requestedLastActivitySeen != null)
      return {
        ChatField.LastActivityTime.value: lastActivityTime,
        ChatField.RequestedLastActivitySeen.value: requestedLastActivitySeen,
      };
    else if (requesterLastActivitySeen != null &&
        requestedLastActivitySeen != null)
      return {
        ChatField.RequesterLastActivitySeen.value: requesterLastActivitySeen,
        ChatField.RequestedLastActivitySeen.value: requestedLastActivitySeen,
      };
    else if (lastActivityTime != null)
      return {ChatField.LastActivityTime.value: lastActivityTime};
    else if (requesterLastActivitySeen != null)
      return {
        ChatField.RequesterLastActivitySeen.value: requesterLastActivitySeen
      };
    else if (requestedLastActivitySeen != null)
      return {
        ChatField.RequestedLastActivitySeen.value: requestedLastActivitySeen
      };
    return null;
  }
}
