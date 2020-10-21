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
  Future<Stream<QuerySnapshot>> getChats(String userID) async {
    return _firestore
        .collection(RootKey)
        .where(ChatField.UserIDs.value, arrayContains: userID)
        .snapshots();
  }
}
