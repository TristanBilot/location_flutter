import 'dart:collection';
import '../models/user.dart';

class CacheManager {
  HashMap<String, User> _cache;

  CacheManager() {
    _cache = HashMap();
  }

  void putUser(User user) {
    _cache[user.email] = user;
  }

  User getUser(String id) {
    return _cache[id];
  }

  getUserImage(String id) {
    final user = getUser(id);
    // DefaultCacheManager().getSingleFile(user.)
  }
}
