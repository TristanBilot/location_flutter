import 'dart:collection';
import '../models/user.dart';

class UserCache {
  static HashMap<String, User> _cache;

  static void init() {
    _cache = HashMap();
  }

  static void putUser(User user) {
    _cache[user.email] = user;
  }

  static User getUser(String id) {
    return _cache[id];
  }

  static bool userExists(String id) {
    return _cache.containsKey(id);
  }
}
