import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import 'package:location_project/conf/extensions.dart';

enum MessageField {
  Message,
  SentBy,
  SentTo,
  Time,
  IsViewed,
  Reaction,
}

class Message implements FirestoreEntry {
  final String message;
  final String sentBy;
  final String sentTo;
  final int time;
  final bool isViewed;
  final Reaction reaction;

  static get Time => DateTime.now().microsecondsSinceEpoch;

  Message(
    this.message,
    this.sentBy,
    this.sentTo,
    this.time,
    this.isViewed,
    this.reaction,
  );

  @override
  bool get stringify => null;

  @override
  List<Object> get props => [message, sentBy, sentTo, time, isViewed];

  dynamic toFirestoreObject() {
    return {
      MessageField.Message.value: message,
      MessageField.SentBy.value: sentBy,
      MessageField.SentTo.value: sentTo,
      MessageField.Time.value: time,
      MessageField.IsViewed.value: isViewed,
      MessageField.Reaction.value: reaction.value,
    };
  }

  static Message fromFirestoreObject(dynamic data) {
    return Message(
      data[MessageField.Message.value],
      data[MessageField.SentBy.value],
      data[MessageField.SentTo.value],
      data[MessageField.Time.value],
      data[MessageField.IsViewed.value],
      ReactionExtension.fromString(data[MessageField.Reaction.value]),
    );
  }
}
