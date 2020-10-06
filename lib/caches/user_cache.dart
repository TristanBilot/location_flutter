import 'dart:collection';

import '../models/user.dart';

class UserCache {
  static HashMap<String, User> _cache;
  static bool isInit = false;

  static void init(User loggedUser) {
    _cache = HashMap();
    _putLoggedUser(loggedUser);
    isInit = true;
  }

  /* 
  * functions used to cache the fetched users
  */
  static void putUser(User user) {
    _cache[user.email] = user;
  }

  static User getUser(String id) {
    return _cache[id];
  }

  static bool userExists(String id) {
    return _cache.containsKey(id);
  }

  /*
  * the logged user is the current user logged in 
  * the app
  */
  static void _putLoggedUser(User user) {
    _cache['loggedUser'] = user;
  }

  static User get getLoggedUser => _cache['loggedUser'];
}
