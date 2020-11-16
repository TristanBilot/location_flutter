import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import '../../../../stores/extensions.dart';

enum MessageField {
  Message,
  SendBy,
  Time,
  IsViewed,
  Reaction,
}

class Message implements FirestoreEntry {
  final String message;
  final String sendBy;
  final int time;
  final bool isViewed;
  final Reaction reaction;

  static get Time => DateTime.now().microsecondsSinceEpoch;

  Message(
    this.message,
    this.sendBy,
    this.time,
    this.isViewed,
    this.reaction,
  );

  @override
  bool get stringify => null;

  @override
  List<Object> get props => [message, sendBy, time, isViewed];

  dynamic toFirestoreObject() {
    return {
      MessageField.Message.value: message,
      MessageField.SendBy.value: sendBy,
      MessageField.Time.value: time,
      MessageField.IsViewed.value: isViewed,
      MessageField.Reaction.value: reaction.value,
    };
  }

  static Message fromFirestoreObject(dynamic data) {
    return Message(
      data[MessageField.Message.value],
      data[MessageField.SendBy.value],
      data[MessageField.Time.value],
      data[MessageField.IsViewed.value],
      ReactionExtension.fromString(data[MessageField.Reaction.value]),
    );
  }
}
