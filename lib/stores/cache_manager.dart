import 'dart:collection';

class CacheManager {
  static HashMap<String, dynamic> _cache;

  static void init() {
    _cache = HashMap();
  }

  static void put(String key, dynamic value) {
    _cache[key] = value;
  }

  static dynamic get(String key) {
    return _cache[key];
  }

  static bool keyExists(String key) {
    return _cache.containsKey(key);
  }
}
