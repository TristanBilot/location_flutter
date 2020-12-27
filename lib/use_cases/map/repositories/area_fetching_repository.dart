import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/helpers/user_icon_cropper.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/conf/extensions.dart';
import 'dart:async';

class AreaFetchingRepository {
  Geoflutterfire _geo;
  FirebaseFirestore _firestore;

  static final double radius = 30000; // in meters

  AreaFetchingRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
  }

  Stream<List<DocumentSnapshot>> fetch() {
    final ref = _firestore.collection(UserRepository.RootKey);

    final GeoFirePoint center = Conf.testMode
        ? Store.parisGeoPosition
        : LocationCache().locationGeoPoint;
    Stream<List<DocumentSnapshot>> stream = _geo
        .collection(collectionRef: ref)
        .within(
            center: center,
            radius: radius / 1000,
            field: UserField.Position.value);
    return stream;
  }

  Future<void> listenAreaStream(
    Stream<List<DocumentSnapshot>> stream,
    Function(List<User>) completion,
  ) async {
    stream.listen((List<DocumentSnapshot> snapshots) async {
      Logger().v('=> ${snapshots.length} users in area.');
      List<User> usersList = List();

      for (int i = 0; i < snapshots.length; i++) {
        final snapshot = snapshots[i];
        final data = snapshot.data();
        final id = snapshot.id;
        final geoPoint = data[UserField.Position.value]['geopoint'];
        User user;

        if (!_displayConditions(data, id)) continue;
        if (MemoryStore().containsUser(id)) user = MemoryStore().getUser(id);

        user = await UserRepository().fetchUser(
          id,
          fromSnapshot: snapshot,
          useCache: true,
          withBlocks: true,
          withInfos: true,
        );
        user.icon = await UserIconCropper(user.mainPictureURL).crop();
        user.coord = List<double>.from([geoPoint.latitude, geoPoint.longitude]);

        MemoryStore().putUser(user);
        usersList.add(user);
        completion(usersList);

        print('=> in area: ${user.email} at ${user.distance} meters (cached).');
      }
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
