enum NotifField {
  notification,
  body,
  fromID,

  data,
  type,
}

enum NotifType {
  unknown,
  message,
}

class Notif {
  static NotifType fromString(String type) {
    switch (type) {
      case 'message':
        return NotifType.message;
    }
    return NotifType.unknown;
  }
}
