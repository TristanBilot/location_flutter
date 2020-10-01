import 'dart:collection';
import '../models/user.dart';

class CacheManager {
  static HashMap<String, dynamic> _cache;

  static void init() {
    _cache = HashMap();
  }

  static void putUser(User user) {
    _cache[user.email] = user;
  }

  static void putDyn(String key, dynamic value) {
    _cache[key] = value;
  }

  static dynamic getDyn(String key) {
    return _cache[key];
  }

  static User getUser(String id) {
    return _cache[id];
  }

  static bool userExists(String id) {
    return _cache.containsKey(id);
  }
}
