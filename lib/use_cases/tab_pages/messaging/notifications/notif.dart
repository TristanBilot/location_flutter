enum NotifField {
  notification,
  body,
  fromID,

  data,
  type,
}

enum NotifType {
  Unknown,
  Message,
  Match,
  View,
  Like,
}

class Notif {
  static NotifType fromString(String type) {
    if (type == null) return NotifType.Unknown;
    switch (type) {
      case 'Message':
        return NotifType.Message;
      case 'Match':
        return NotifType.Match;
      case 'View':
        return NotifType.View;
      case 'Like':
        return NotifType.Like;
    }
    return NotifType.Unknown;
  }
}
