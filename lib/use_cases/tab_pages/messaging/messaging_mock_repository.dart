import 'dart:math';

import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';

class MessagingMockRepository {
  final id1 = 'bilot.tristan@hotmail.fr';
  final id2 = 'damien.duprat@hotmail.fr';
  final id3 = 'alexandre.roume@hotmail.fr';
  final id4 = 'bilot.tristan.carrieres@hotmail.fr';
  final id5 = 'damien.duprat.carrieres@hotmail.fr';
  final id6 = 'alexandre.roume.carrieres@hotmail.fr';

  final id1Name = 'Tristan';
  final id2Name = 'Damien';
  final id3Name = 'Alexandre';

  Future<void> insertChatMock() async {
    _insertChatMock(id1, id2, id1Name, id2Name, true);
    _insertChatMock(id1, id2, id1Name, id2Name, true);
    _insertChatMock(id1, id3, id1Name, id3Name, true);

    _insertChatMock(id1, id4, id1Name, id1Name, true);
    _insertChatMock(id1, id5, id1Name, id2Name, true);
    _insertChatMock(id1, id6, id1Name, id3Name, true);
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
    // await MessagingReposiory().deleteChat(chatID);
    final rd = Random().nextBool();
    final entry = Chat.newChatEntry(
      rd ? id1 : id2,
      rd ? id2 : id1,
      rd ? id1Name : id2Name,
      rd ? id2Name : id1Name,
      engaged,
      !engaged,
      false,
    );
    MessagingReposiory().newChat(entry.chatID, entry);
    print('${entry.chatID} successfully inserted to Firestore.');
  }

  /// Insert a mock message in the Firestore.
  Future<void> _insertMessageMock(
    String id1,
    String id2,
    String message,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1, id2);
    await MessagingReposiory().deleteMessages(chatID);
    final entry = Message(
      message,
      Random().nextBool() == true ? id1 : id2,
      Message.Time,
      false,
    );
    MessagingReposiory().newMessage(chatID, entry);
    print('message successfully inserted to Firestore.');
  }
}
