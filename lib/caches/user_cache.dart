import 'dart:collection';

import '../models/user.dart';

/// Cache used to store only the area users.
/// Logged user is managed bu `UserStore`.
class UserCache {
  HashMap<String, User> _cache;

  UserCache() {
    _cache = HashMap();
  }

  static UserCache _instance;
  static UserCache get instance {
    return (_instance = _instance == null ? UserCache() : _instance);
  }

  /* 
  * functions used to cache the fetched users
  */
  void putUser(User user) {
    _cache[user.email] = user;
  }

  User getUser(String id) {
    return _cache[id];
  }

  bool userExists(String id) {
    return _cache.containsKey(id);
  }
}
