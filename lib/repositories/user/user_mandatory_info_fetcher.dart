import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/storage/shared%20preferences/local_store.dart';

class UserMandatoryInfo implements TimeMeasurable {
  int timeToFetch;
  String id;
  String email;
  String firstName;
  String lastName;
  List<double> coord;
  int distance;
  int age;
  Gender gender;
  UserSettings settings;
  List<String> deviceTokens;
  List<String> pictureURLs;
  final String bio;

  UserMandatoryInfo(
    this.timeToFetch,
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.coord,
    this.distance,
    this.age,
    this.gender,
    this.settings,
    this.deviceTokens,
    this.pictureURLs,
    this.bio,
  );

  static final UserMandatoryInfo userMandatoryInfoNotFound = UserMandatoryInfo(
      0,
      null,
      null,
      null,
      null,
      [0, 0],
      0,
      0,
      Gender.Other,
      UserSettings.DefaultUserSettings,
      [],
      [LocalStore().getNotFoundImagePictureURL()],
      '?');
}

class UserMandatoryInfoFetcher {
  Future<UserMandatoryInfo> fetch(String id) async {
    final snapshot = await UserRepository().fetchUserDocumentSnapshot(id);
    return fetchFromSnapshot(snapshot);
  }

  UserMandatoryInfo fetchFromSnapshot(DocumentSnapshot snapshot) {
    Stopwatch stopwatch = Stopwatch()..start();
    final id = snapshot.id;
    final Map<String, dynamic> data = snapshot.data();
    if (data == null) {
      Logger().e('An invalid id or invalid snapshot has been fetched');
      return UserMandatoryInfo.userMandatoryInfoNotFound;
    }
    final realPosition = //await LocationController().isLocationEnabled() &&
        LocationCache().isLocationAvailable
            ? LocationCache().locationGeoPoint
            : LocationCache().dummyLocationGeoPoint;
    final GeoFirePoint center =
        Conf.testMode ? Store.parisGeoPosition : realPosition;
    final geoPoint = data[UserField.Position.value]['geopoint'];
    final geoFirePoint = GeoFirePoint(geoPoint.latitude, geoPoint.longitude);
    final distance = (GeoFirePoint.distanceBetween(
                to: center.coords, from: geoFirePoint.coords) *
            1000)
        .toInt();

    final settings = UserSettings.fromFirestoreObject(data);
    final firstName = data[UserField.FirstName.value];
    final lastName = data[UserField.LastName.value];
    final coord = List<double>.from([geoPoint.latitude, geoPoint.longitude]);
    final gender =
        GenderValueAdapter().stringToGender(data[UserField.Gender.value]);
    final age = data[UserField.Age.value];
    final deviceTokens =
        (data[UserField.DeviceTokens.value] as List)?.cast<String>();
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    final pictureURLs =
        (data[UserField.PictureURLs.value] as List)?.cast<String>();
    final bio = data[UserField.Bio.value];
    return UserMandatoryInfo(timeToFetch, id, id, firstName, lastName, coord,
        distance, age, gender, settings, deviceTokens, pictureURLs, bio);
  }
}
