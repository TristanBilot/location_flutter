import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/conf/extensions.dart';
import 'dart:async';
import '../../../repositories/image_repository.dart';
import '../../../models/user.dart';

class AreaFetchingRepository {
  Geoflutterfire _geo;
  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  static final double radius = 30000; // in meters

  AreaFetchingRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
  }

  /// Get the current location and fetch all the users
  /// in the defined radius thanks to Geoflutterfire.
  /// It returns the stream of User snapshots.
  Stream<List<DocumentSnapshot>> fetch() {
    final ref = _firestore.collection('locations');

    final GeoFirePoint center = Conf.testMode
        ? Store.parisGeoPosition
        : LocationCache().locationGeoPoint;
    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: ref)
        .within(
            center: center,
            radius: radius / 1000,
            field: UserField.Position.value);
    // return _listenAreaStream(stream, completion);
    return stream;
  }

  /// Listens to the stream of users around the current location.
  /// For each user around, the picture is fetched and a User object
  /// is created. The completion is used to setState() in the view
  /// to update the list of markers to display to the map.
  Future<void> listenAreaStream(
      Stream<List<DocumentSnapshot>> stream, Function completion) async {
    stream.listen((List<DocumentSnapshot> users) async {
      Logger().v('=> ${users.length} users in area.');
      int userCount = 0;
      List<User> usersList = List();
      users.forEach((user) async {
        userCount++;
        final data = user.data();
        final id = user.id;

        if (_displayConditions(data, id)) {
          // fresh position of each user.
          final geoPoint = user.data()[UserField.Position.value]['geopoint'];

          User newUser = await UserRepository().fetchUser(
            id,
            fromSnapshot: user,
            useCache: true,
            withBlocks: true,
            withIcon: true,
            withInfos: true,
          );
          // updates the coords in the cache.
          newUser.coord =
              List<double>.from([geoPoint.latitude, geoPoint.longitude]);

          MemoryStore().putUser(newUser);
          usersList.add(newUser);
          print(
              '=> in area: ${newUser.email} at ${newUser.distance} meters (cached).');
        }
        /* userCount used to know when the last user is reached */
        if (userCount == users.length) completion(usersList);
      });
    });
  }

  /// Return true if a user should be shown on the map.
  /// All the conditions should be centralized in this method.
  bool _displayConditions(dynamic data, String id) {
    final areaUserGender = GenderValueAdapter()
        .stringToGender(data[UserField.Gender.value] as String);
    final areaUserGenders = GenderValueAdapter().stringsToGenders(
        List<String>.from(data[UserField.WantedGenders.value]));
    final userGender = UserStore().user.gender;
    final userGenders = UserStore().user.settings.wantedGenders;

    bool genderMatch = userGenders.contains(areaUserGender) &&
        areaUserGenders.contains(userGender);
    bool showProfile = data[UserField.ShowMyProfile.value] as bool;
    bool differentFromLoggedUser = UserStore().user.id != id;
    bool notBlocked = !UserStore().user.blockedUserIDs.contains(id);
    bool userNotBlockedMe = !UserStore().user.userIDsWhoBlockedMe.contains(id);
    return showProfile &&
        genderMatch &&
        differentFromLoggedUser &&
        notBlocked &&
        userNotBlockedMe;
  }
}
