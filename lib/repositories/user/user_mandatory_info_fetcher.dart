import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user/time_measurable.dart';
import 'package:location_project/stores/conf.dart';
import 'package:location_project/stores/store.dart';
import '../../stores/extensions.dart';

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
  );
}

class UserMandatoryInfoFetcher {
  UserMandatoryInfo fetch(
    DocumentSnapshot snapshot,
  ) {
    Stopwatch stopwatch = Stopwatch()..start();
    final id = snapshot.id;
    final Map<String, dynamic> data = snapshot.data();
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
    final timeToFetch = stopwatch.elapsed.inMilliseconds;
    return UserMandatoryInfo(timeToFetch, id, id, firstName, lastName, coord,
        distance, age, gender, settings);
  }
}
