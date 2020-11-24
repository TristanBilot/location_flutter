enum NotifField {
  notification,
  body,
  fromID,

  data,
  type,
}

enum NotifType {
  Unknown,
  Messages,
  Requests,
  Chats,
  Views,
}

class Notif {
  static NotifType fromString(String type) {
    switch (type) {
      case 'Messages':
        return NotifType.Messages;
      case 'Chats':
        return NotifType.Chats;
      case 'Requests':
        return NotifType.Requests;
      case 'Views':
        return NotifType.Views;
    }
    return NotifType.Unknown;
  }
}
