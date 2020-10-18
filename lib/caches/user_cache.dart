import 'dart:collection';

import '../models/user.dart';

/// Cache used to store only the area users.
/// Logged user is managed by `UserStore`.
class UserCache {
  HashMap<String, User> _cache = HashMap();

  UserCache._internal();
  static final UserCache _instance = UserCache._internal();

  factory UserCache() => _instance;

  /* 
  * functions used to cache the fetched users
  */
  void putUser(User user) {
    _cache[user.id] = user;
  }

  User getUser(String id) {
    return _cache[id];
  }

  bool userExists(String id) {
    return _cache.containsKey(id);
  }
}
