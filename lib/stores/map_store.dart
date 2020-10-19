import 'package:location_project/models/user.dart';

/// Singleton class.
/// Manage the persistent data of the map.
/// Store the like/unliked users.
class MapStore {
  List<User> _unlikedUsers = List();
  List<User> get unlikedUsers => _unlikedUsers;

  MapStore._internal();
  static final MapStore _instance = MapStore._internal();

  factory MapStore() => _instance;

  void addUnlikedUser(User user) {
    print(this.hashCode);
    _unlikedUsers.add(user);
  }

  bool isUserUnliked(String id) {
    if (_unlikedUsers.isEmpty) return false;
    return _unlikedUsers.firstWhere(
          (user) => user.id == id,
          orElse: () => null,
        ) !=
        null;
  }
}
