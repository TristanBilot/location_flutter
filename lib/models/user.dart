import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/helpers/gender_adapter.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/stores/conf.dart';
import 'package:location_project/stores/store.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

enum UserField {
  FirstName,
  LastName,
  Position,
  Age,
  Gender,

  WantedGenders,
  WantedAgeRange,
  ShowMyProfile,
  ShowMyDistance,
  Connected,
}

class User {
  String id;
  String email;
  String firstName;
  String lastName;
  LatLng coord;
  BitmapDescriptor icon;
  String pictureURL;
  int distance;
  int age;
  Gender gender;
  UserSettings settings;

  User(
      String email,
      String firstName,
      String lastName,
      LatLng coord,
      BitmapDescriptor icon,
      String pictureURL,
      int distance,
      int age,
      Gender gender,
      UserSettings settings) {
    this.id = email;
    this.lastName = lastName;
    this.firstName = firstName;
    this.email = email;
    this.coord = coord;
    this.icon = icon;
    this.pictureURL = pictureURL;
    this.distance = distance;
    this.age = age;
    this.gender = gender;
    this.settings = settings;
  }

  /// Returns a User from a Firestore snapshot, the snaposhot
  /// is needed to get the id which is the email, then data()
  /// gives all the user's data.
  static Future<User> from(DocumentSnapshot snapshot) async {
    final Map<String, dynamic> data = snapshot.data();
    final _imageRepo = ImageRepository();
    final realPosition = (await LocationController().isLocationEnabled() &&
            LocationCache().isLocationAvailable)
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

    final icon = await _imageRepo.fetchUserIcon(snapshot.id);
    final downloadURL = await _imageRepo.getPictureDownloadURL(snapshot.id);
    final settings = UserSettings.fromFirestoreObject(data);

    final firstName = data[UserField.FirstName.value];
    final lastName = data[UserField.LastName.value];
    final coord = LatLng(geoPoint.latitude, geoPoint.longitude);
    final gender = GenderAdapter().stringToGender(data[UserField.Gender.value]);
    final age = data[UserField.Age.value];

    return User(snapshot.id, firstName, lastName, coord, icon, downloadURL,
        distance, age, gender, settings);
  }

  /// Return the user corresponding to the id if it
  /// exists in the cache, or null.
  static User fromCache(String id) {
    if (!UserCache().userExists(id)) return null;
    return UserCache().getUser(id);
  }
}
