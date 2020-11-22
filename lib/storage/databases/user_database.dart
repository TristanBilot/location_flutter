import 'package:hive/hive.dart';
import 'package:location_project/models/user.dart';

/// The database is used to store locally data
/// on the physical device. Unlike the store, it is store
/// in a file and not only in memory.
class UserDatabase {
  static const UserBox = 'User';
  static const MessagingBox = 'Messaging';

  static const UserPrefix = 'user_';
  static const MessagingPrefix = 'messaging_';

  static Future<void> initHiveDatabase() async {
    _instance._box = await Hive.openBox(UserBox);
  }

  UserDatabase._internal();
  static final UserDatabase _instance = UserDatabase._internal();
  factory UserDatabase() => _instance;

  Box _box;

  /// Return wether a key exists in the database.
  bool keyExists(dynamic key) {
    return _box.containsKey(key);
  }

  /// Insert a user in the database.
  Future<void> putUser(User user) async {
    _box.put(user.id, user);
  }

  /// Return a User from the database.
  User getUser(String id) {
    return _box.get(id);
  }

  /// Delete a user from the database.
  Future<void> deleteUser(String id) async {
    _box.delete(id);
  }

  /// Return a User as a Future for the FutureBuilder.
  Future<User> getFutureUser(String id) async {
    asyncStuff() async => {};
    asyncStuff();
    return _box.get(id);
  }

  Future<void> clear() async {
    _box.deleteFromDisk();
  }

  // Future<void> manageCache(User user) async {
  //   if (UserDatabase().keyExists(user.id)) {
  //     final cachedUser = UserDatabase().getUser(user.id);
  //     if (cachedUser.id != user.id) cachedUser.id = user.id;
  //     if (cachedUser.email != user.email) cachedUser.email = user.email;
  //     if (cachedUser.firstName != user.firstName)
  //       cachedUser.firstName = user.firstName;
  //     if (cachedUser.lastName != user.lastName)
  //       cachedUser.lastName = user.lastName;
  //     if (cachedUser.age != user.age) cachedUser.age = user.age;
  //     if (cachedUser.coord != user.coord) cachedUser.coord = user.coord;
  //     if (cachedUser.distance != user.distance)
  //       cachedUser.distance = user.distance;
  //     if (cachedUser.gender != user.gender) cachedUser.gender = user.gender;
  //     if (cachedUser.pictureURL != user.pictureURL)
  //       cachedUser.pictureURL = user.pictureURL;
  //     if (cachedUser.settings != user.settings)
  //       cachedUser.settings = user.settings;
  //     cachedUser.save();
  //   } else
  //     UserDatabase().putUser(user);
  // }
}