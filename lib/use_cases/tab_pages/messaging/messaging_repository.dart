import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/stream_adapter.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import '../../../stores/extensions.dart';

class MessagingReposiory {
  static const RootKey = 'messages';
  static const ChatKey = 'chats';

  FirebaseFirestore _firestore;

  MessagingReposiory() {
    _firestore = FirebaseFirestore.instance;
  }
  // messages => id1_id2 => chats => msgID

  /// By default, the chatID is the concatenation of
  /// the two participants IDs unioned with an _.
  static String getChatID(String id1, String id2) {
    return [id1, id2].join('_');
  }

  /// Create the first chat between 2 users.
  Future<void> newChat(String chatID, Chat chat) async {
    _firestore
        .collection(RootKey) // messages
        .doc(chatID) // email1_email2
        .set(chat.toFirestoreObject())
        .catchError((e) => print(e));
  }

  /// Remove a chat between two participants. Used when a requested
  /// user deny a request.
  Future<void> deleteChat(String chatID) async {
    _firestore.collection(RootKey).doc(chatID).delete();
  }

  /// Update tghe boolean value if `IsChatEngaged` in the chat.
  /// This is used when a requested user accept a request.
  Future<void> updateChatEngaged(String chatID, bool isEngaged) async {
    _firestore.collection(RootKey).doc(chatID).update({
      ChatField.IsChatEngaged.value: isEngaged,
    }).catchError((e) => print(e));
  }

  /// Update the values of `lastActivityTime` and `lastActivitySeen`
  /// in the chat, so that we can fetch the last chat and know
  /// if a message had been opened.
  Future<void> updateChatLastActivity(
    String chatID, {
    int lastActivityTime,
    bool lastActivitySeen,
  }) async {
    final toUpdate =
        Chat.getCorrespondingUpdateObject(lastActivityTime, lastActivitySeen);
    if (toUpdate == null) {
      Logger().e('`updateChatLastActivity()` need parameters.');
      return;
    }
    _firestore
        .collection(RootKey)
        .doc(chatID)
        .update(toUpdate)
        .catchError((e) => print(e));
  }

  /// Return a stream of messages ordered by time from a chat ID.
  /// `descending` set to true because the list is reversed in
  /// the ListView builder UI.
  Future<Stream<QuerySnapshot>> getMessages(String chatID) async {
    return _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .orderBy(MessageField.Time.value, descending: true)
        .snapshots();
  }

  /// Return the last message sent in a chat.
  Future<QuerySnapshot> getLastMessage(String chatID) async {
    return _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .orderBy(MessageField.Time.value, descending: true)
        .limit(1)
        .snapshots()
        .first
        .catchError((e) => print('++++ error in getLastMessage()'));
  }

  /// By default, Firestore does not delete subcollections of collections.
  /// So we need to delete them manually with a for loop.
  Future<void> deleteMessages(String chatID) async {
    _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) doc.reference.delete();
    });
  }

  /// Insert a new message in the chat `chatID`.
  Future<void> newMessage(String chatID, FirestoreMessageEntry msg) async {
    _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .add(msg.toFirestoreObject())
        .catchError((e) => print(e.toString()));
  }

  Stream<List<Chat>> getChats(String userID) {
    return _firestore
        .collection(RootKey)
        .where(ChatField.UserIDs.value, arrayContains: userID)
        .snapshots()
        .transform(StreamAdapter().mapToListOf<Chat>());
  }

  /// Returns the firestore chat designed by the `chatID`.
  Future<DocumentSnapshot> getChat(String chatID) async {
    return _firestore.collection(RootKey).doc(chatID).snapshots().first;
  }
}