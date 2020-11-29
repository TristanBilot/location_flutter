import 'dart:collection';

import '../../models/user.dart';

/// Cache used to store the area users and memory-only data.
/// Logged user is managed by `UserStore`.
class MemoryStore {
  MemoryStore._internal();
  static final MemoryStore _instance = MemoryStore._internal();
  factory MemoryStore() => _instance;

  /* 
  * functions used to cache the fetched users
  */
  HashMap<String, User> _areaUsersCache = HashMap();
  void putUser(User user) => _areaUsersCache[user.id] = user;
  User getUser(String id) => _areaUsersCache[id];
  bool userExists(String id) => _areaUsersCache.containsKey(id);
  List<User> get users => _areaUsersCache.values.toList();
  bool containsUser(String id) => _areaUsersCache.containsKey(id);

  /*
  * displaying of toast notifications
  */
  String _userChattingWithNow = '';
  get getUserChattingWithNow => _userChattingWithNow;

  bool _displayMessageToast = true;
  get shouldDisplayMessageToast => _displayMessageToast;

  bool _displayChatToast = true;
  get shouldDisplayChatToast => _displayChatToast;

  bool _displayRequestToast = true;
  get shouldDisplayRequestToast => _displayRequestToast;

  bool _displayViewToast = true;
  get shouldDisplayViewToast => _displayViewToast;

  void setDisplayToastValues(
    bool displayChats,
    bool displayRequests,
    bool displayViews,
    bool displayMessageToast,
    String userChattingWithMeNow,
  ) {
    _displayChatToast = displayChats;
    _displayRequestToast = displayRequests;
    _displayViewToast = displayViews;
    _displayMessageToast = displayMessageToast;
    _userChattingWithNow = userChattingWithMeNow;
  }
}
