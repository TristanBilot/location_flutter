enum NotifField {
  notification,
  title,
  body,

  data,
  type,
}

enum NotifType {
  unknown,
  message,
}

class Notif {
// final String message;

// Notif.fromJson(dynamic data) {
//   this
// }
  static NotifType fromString(String type) {
    switch (type) {
      case 'message':
        return NotifType.message;
    }
    return NotifType.unknown;
  }
}
