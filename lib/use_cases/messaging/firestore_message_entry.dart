import 'package:location_project/models/firestore_entry.dart';
import '../../stores/extensions.dart';

enum MessageField {
  Message,
  SendBy,
  Time,
}

class FirestoreMessageEntry implements FirestoreEntry {
  final String message;
  final String sendBy;
  final int time;

  static get Time => DateTime.now().microsecondsSinceEpoch;

  FirestoreMessageEntry(
    this.message,
    this.sendBy,
    this.time,
  );

  dynamic toFirestoreObject() {
    return {
      MessageField.Message.value: message,
      MessageField.SendBy.value: sendBy,
      MessageField.Time.value: time,
    };
  }
}
