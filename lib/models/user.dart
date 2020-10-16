import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/helpers/gender_adapter.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/stores/conf.dart';
import 'package:location_project/stores/store.dart';
import '../stores/extensions.dart';

enum UserField {
  FirstName,
  LastName,
  Position,

  WantedGenders,
  WantedAgeRange,
  ShowMyProfile,
  ShowMyDistance,
}

class User {
  String email;
  String firstName;
  String lastName;
  LatLng coord;
  BitmapDescriptor icon;
  String pictureURL;
  int distance;
  UserSettings settings;

  User(
      String email,
      String firstName,
      String lastName,
      LatLng coord,
      BitmapDescriptor icon,
      String pictureURL,
      int distance,
      UserSettings settings) {
    this.lastName = lastName;
    this.firstName = firstName;
    this.email = email;
    this.coord = coord;
    this.icon = icon;
    this.pictureURL = pictureURL;
    this.distance = distance;
    this.settings = settings;
  }

  /// dynamic x = something();
  /// String s = cast<String>(x);
  static T cast<T>(x) => x is T ? x : null;

  /// Returns a User from a Firestore snapshot, the snaposhot
  /// is needed to get the id which is the email, then data()
  /// gives all the user's data.
  static Future<User> from(DocumentSnapshot snapshot) async {
    final Map<String, dynamic> data = snapshot.data();
    final _imageRepo = ImageRepository();
    final realPosition = (await LocationController.instance.isLocationEnabled())
        ? LocationCache.locationGeoPoint
        : LocationCache.dummyLocationGeoPoint;
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

    return User(
      snapshot.id,
      data[UserField.FirstName.value],
      data[UserField.LastName.value],
      LatLng(geoPoint.latitude, geoPoint.longitude),
      icon,
      downloadURL,
      distance,
      settings,
    );
  }

  static Future<User> fromCache(DocumentSnapshot snapshot) async {
    if (!UserCache.isInit || !UserCache.userExists(snapshot.id)) return null;
    return UserCache.getUser(snapshot.id);
  }
}
