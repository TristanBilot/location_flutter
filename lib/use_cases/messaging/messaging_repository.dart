import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import '../../stores/extensions.dart';

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
  Future<void> newChat(String chatID, FirestoreChatEntry chat) async {
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
    final toUpdate = FirestoreChatEntry.getCorrespondingUpdateObject(
        lastActivityTime, lastActivitySeen);
    if (toUpdate == null) {
      print('+++ `updateChatLastActivity()` need parameters.');
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
        .catchError((e) => print('hello'));
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

  /// Returns a stream of chats linked to the user logged `userID`.
  /// The chats are sorted by last time in the stream builder because
  /// where() + orderBy() are not working together currently.
  Future<Stream<QuerySnapshot>> getChats(String userID) async {
    return _firestore
        .collection(RootKey)
        .where(ChatField.UserIDs.value, arrayContains: userID)
        .snapshots();
  }

  /// Returns the firestore chat designed by the `chatID`.
  Future<DocumentSnapshot> getChat(String chatID) async {
    return _firestore.collection(RootKey).doc(chatID).snapshots().first;
  }
}
