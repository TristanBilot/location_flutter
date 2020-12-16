import 'dart:math';

import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';

class MessagingMockRepository {
  final id1 = {'id': 'bilot.tristan@hotmail.fr', 'name': 'Tristan'};
  final id2 = {'id': 'damien.duprat@hotmail.fr', 'name': 'Damien'};
  final id3 = {'id': 'alexandre.roume@hotmail.fr', 'name': 'Alexandre'};
  final id4 = {'id': 'bilot.tristan.carrieres@hotmail.fr', 'name': 'Tristan'};
  final id5 = {'id': 'damien.duprat.carrieres@hotmail.fr', 'name': 'Damien'};
  final id6 = {
    'id': 'alexandre.roume.carrieres@hotmail.fr',
    'name': 'Alexandre'
  };

  Future<void> insertChatMock() async {
    _insertChatMock(id1, id2, true);
    _insertChatMock(id1, id2, true);
    _insertChatMock(id1, id3, true);

    _insertChatMock(id1, id4, true);
    _insertChatMock(id1, id5, true);
    _insertChatMock(id1, id6, true);
  }

  Future<void> insertMessageMock() async {
    final nb = 15;
    for (int i = 0; i < nb; i++) _insertMessageMock(id1, id2, 'Message n°$i');
    for (int i = 0; i < nb; i++) _insertMessageMock(id1, id3, 'Message n°$i');
  }

  /// Insert a mock chat in the Firestore.
  Future<void> _insertChatMock(
    dynamic id1,
    dynamic id2,
    bool engaged,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1['id'], id2['id']);
    // await MessagingReposiory().deleteChat(chatID);
    final rd = Random().nextBool();
    final entry = Chat.newChatEntry(
      rd ? id1['id'] : id2['id'],
      rd ? id2['id'] : id1['id'],
      rd ? id1['name'] : id2['name'],
      rd ? id2['name'] : id1['name'],
      engaged,
      !engaged,
      false,
    );
    MessagingReposiory().newChat(entry.chatID, entry);
    print('${entry.chatID} successfully inserted to Firestore.');
  }

  /// Insert a mock message in the Firestore.
  Future<void> _insertMessageMock(
    dynamic id1,
    dynamic id2,
    String message,
  ) async {
    final chatID = MessagingReposiory.getChatID(id1['id'], id2['id']);
    await MessagingReposiory().deleteMessages(chatID);
    final sentBy = Random().nextBool() == true ? id1 : id2;
    final sentTo = sentBy == id1 ? id2 : id1;
    final entry = Message(
      message,
      sentBy['id'],
      sentTo['id'],
      Message.Time,
      false,
      Reaction.NoReaction,
      sentBy['name'],
    );
    MessagingReposiory().newMessage(chatID, entry);
    print('message successfully inserted to Firestore.');
  }
}
