import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/stream_adapter.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import 'package:location_project/conf/extensions.dart';

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
    return ([id1, id2]..sort()).join('_');
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

  Future<void> deleteMessage(String chatID, Message message) async {
    _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .where(MessageField.Time.value, isEqualTo: message.time)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) doc.reference.delete();
    });
  }

  /// Update tghe boolean value if `IsChatEngaged` in the chat.
  /// This is used when a requested user accept a request.
  Future<void> updateChatEngaged(String chatID, bool isEngaged) async {
    _firestore.collection(RootKey).doc(chatID).update({
      ChatField.IsChatEngaged.value: isEngaged,
    }).catchError((e) => print(e));
  }

  Future<void> updateChatLastActivity(
    Chat chat, {
    int lastActivityTime,
    bool lastActivitySeen,
    Participant lastActivitySeenParticipant,
  }) async {
    if (lastActivitySeen != null && lastActivitySeenParticipant == null ||
        lastActivitySeenParticipant != null && lastActivitySeen == null)
      Logger().e(
          '`updateLoggedUserChatLastActivity()` LastActivitySeen should design a participant.');
    dynamic toUpdate;
    if (lastActivitySeenParticipant == Participant.Me) {
      toUpdate = Chat.getCorrespondingUpdateObject(
        lastActivityTime: lastActivityTime,
        requesterLastActivitySeen: chat.iAmRequester ? lastActivitySeen : null,
        requestedLastActivitySeen: !chat.iAmRequester ? lastActivitySeen : null,
      );
    } else if (lastActivitySeenParticipant == Participant.Other) {
      toUpdate = Chat.getCorrespondingUpdateObject(
        lastActivityTime: lastActivityTime,
        requesterLastActivitySeen: !chat.iAmRequester ? lastActivitySeen : null,
        requestedLastActivitySeen: chat.iAmRequester ? lastActivitySeen : null,
      );
    } else
      Logger().e(
          '`updateLoggedUserChatLastActivity()` This user is not a correct user.');
    if (toUpdate == null) {
      Logger().e('`updateChatLastActivity()` need parameters.');
      return;
    }
    _firestore
        .collection(RootKey)
        .doc(chat.chatID)
        .update(toUpdate)
        .catchError((e) => print(e));
  }

  /// Return a stream of messages ordered by time from a chat ID.
  /// `descending` set to true because the list is reversed in
  /// the ListView builder UI.
  Stream<QuerySnapshot> getMessages(String chatID) {
    return _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .orderBy(MessageField.Time.value, descending: true)
        .limit(20)
        .snapshots();
  }

  // Future<Stream<QuerySnapshot>> getMoreMessages(
  //     String chatID, Message lastMsg) async {
  //   final lastDoc = await _firestore
  //       .collection(RootKey)
  //       .doc(chatID)
  //       .collection(ChatKey)
  //       .doc(lastMsg.docID)
  //       .get();

  //   return _firestore
  //       .collection(RootKey)
  //       .doc(chatID)
  //       .collection(ChatKey)
  //       .startAfterDocument(lastDoc)
  //       .orderBy(MessageField.Time.value, descending: true)
  //       .limit(20)
  //       .snapshots();
  // }

  /// Return the last message sent in a chat.
  Stream<List<Message>> getLastMessage(String chatID) {
    return _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(ChatKey)
        .orderBy(MessageField.Time.value, descending: true)
        .limit(1)
        .snapshots()
        .transform(StreamAdapter().mapToListOfEntries<Message>());
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
  Future<void> newMessage(String chatID, Message msg) async {
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
        .transform(StreamAdapter().mapToListOfEntries<Chat>());
  }

  /// Returns the firestore chat designed by the `chatID`.
  Future<DocumentSnapshot> getChat(String chatID) async {
    return _firestore.collection(RootKey).doc(chatID).snapshots().first;
  }

  Future<Chat> getChatAsChat(String chatID) async {
    final snapshot = await _firestore.collection(RootKey).doc(chatID).get();
    return Chat.fromFirestoreObject(snapshot.data());
  }

  void updateLastMessageView(Chat chat, bool isViewed) {
    _firestore
        .collection(RootKey)
        .doc(chat.chatID)
        .collection(ChatKey)
        .orderBy(MessageField.Time.value, descending: true)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs == null || snapshot.docs.isEmpty) return;
      snapshot.docs.first.reference
          .update({MessageField.IsViewed.value: isViewed});
    });
  }

  void updateMessageReaction(Chat chat, Message message, Reaction reaction) {
    _firestore
        .collection(RootKey)
        .doc(chat.chatID)
        .collection(ChatKey)
        .where(MessageField.Time.value, isEqualTo: message.time)
        .get()
        .then((snapshot) {
      if (snapshot.docs == null || snapshot.docs.isEmpty) return;
      snapshot.docs.first.reference.update({
        MessageField.Reaction.value: reaction.value,
      });
    });
  }
}
