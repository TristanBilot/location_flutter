import 'package:location_project/models/user.dart';

class MapStore {
  List<User> _unlikedUsers;
  List<User> get unlikedUsers => _unlikedUsers;

  static MapStore _instance;
  static MapStore get instance {
    return (_instance = _instance == null ? MapStore() : _instance);
  }

  MapStore() {
    _unlikedUsers = List();
  }

  void addUnlikedUser(User user) {
    print(this.hashCode);
    _unlikedUsers.add(user);
  }

  bool isUserUnliked(String id) {
    if (_unlikedUsers.isEmpty) return false;
    return _unlikedUsers.firstWhere(
          (user) => user.email == id,
          orElse: () => null,
        ) !=
        null;
  }
}
