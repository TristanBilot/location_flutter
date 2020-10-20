import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';

class MessagingMockRepository {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> insertChatMock() async {
    _insertChatMock('bilot.tristan@hotmail.fr', 'damien.duprat@hotmail.fr');
    _insertChatMock('bilot.tristan@hotmail.fr', 'alexandre.roume@hotmail.fr');
  }

  /// Insert a mock chat in the Firestore.
  Future<void> _insertChatMock(
    String id1,
    String id2,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1, id2);
    _firestore
        .collection(MessagingReposiory.RootKey)
        .doc(chatID)
        .set(FirestoreChatEntry(
          [id1, id2],
          chatID,
        ).toFirestoreObject());
    print('$chatID successfully inserted to Firestore.');
  }
}
