import 'dart:io';

import 'package:hive/hive.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:path_provider/path_provider.dart';

/// The database is used to store locally data
/// on the physical device. Unlike the store, it is store
/// in a file and not only in memory.
class Database {
  static const UserBox = 'User';

  static Future<void> initHiveDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(UserAdapter());
    _instance._box = await Hive.openBox(UserBox);
  }

  Database._internal();
  static final Database _instance = Database._internal();
  factory Database() => _instance;

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

  // Future<void> manageCache(User user) async {
  //   if (Database().keyExists(user.id)) {
  //     final cachedUser = Database().getUser(user.id);
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
  //     Database().putUser(user);
  // }
}
