import 'dart:math';

import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';

class MessagingMockRepository {
  final id1 = 'bilot.tristan@hotmail.fr';
  final id2 = 'damien.duprat@hotmail.fr';
  final id3 = 'alexandre.roume@hotmail.fr';

  final id1Name = 'Tristan';
  final id2Name = 'Damien';
  final id3Name = 'Alexandre';

  Future<void> insertChatMock() async {
    _insertChatMock(id1, id2, id1Name, id2Name, true);
    _insertChatMock(id1, id3, id1Name, id3Name, true);
    _insertChatMock(id1, id2, id1Name, id2Name, true);
  }

  Future<void> insertMessageMock() async {
    final nb = 15;
    for (int i = 0; i < nb; i++) _insertMessageMock(id1, id2, 'Message n°$i');
    for (int i = 0; i < nb; i++) _insertMessageMock(id1, id3, 'Message n°$i');
  }

  /// Insert a mock chat in the Firestore.
  Future<void> _insertChatMock(
    String id1,
    String id2,
    String id1Name,
    String id2Name,
    bool engaged,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1, id2);
    final rd = Random().nextBool();
    final entry = FirestoreChatEntry(
      [id1, id2],
      [id1Name, id2Name],
      chatID,
      FirestoreMessageEntry.Time,
      false,
      engaged,
      rd == true ? id1 : id2,
      rd == true ? id2 : id1,
    );
    MessagingReposiory().newChat(chatID, entry);
    print('$chatID successfully inserted to Firestore.');
  }

  /// Insert a mock message in the Firestore.
  Future<void> _insertMessageMock(
    String id1,
    String id2,
    String message,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1, id2);
    final entry = FirestoreMessageEntry(
      message,
      Random().nextBool() == true ? id1 : id2,
      FirestoreMessageEntry.Time,
    );
    MessagingReposiory().newMessage(chatID, entry);
    print('message successfully inserted to Firestore.');
  }
}
