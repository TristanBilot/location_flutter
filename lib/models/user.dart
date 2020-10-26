import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/helpers/gender_value_adapter.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/stores/conf.dart';
import 'package:location_project/stores/store.dart';
import 'package:location_project/models/gender.dart';
import '../stores/extensions.dart';

part 'user.g.dart';

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

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String email;
  @HiveField(2)
  String firstName;
  @HiveField(3)
  String lastName;
  @HiveField(4)
  List<double> coord; // [0]: latitude [1]: longitude
  BitmapDescriptor icon;
  @HiveField(5)
  String pictureURL;
  @HiveField(6)
  int distance;
  @HiveField(7)
  int age;
  @HiveField(8)
  Gender gender;
  @HiveField(9)
  UserSettings settings;

  User._();

  User(
    this.email,
    this.firstName,
    this.lastName,
    this.coord,
    this.icon,
    this.pictureURL,
    this.distance,
    this.age,
    this.gender,
    this.settings,
  ) {
    this.id = email;
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
    final coord = List<double>.from([geoPoint.latitude, geoPoint.longitude]);
    final gender =
        GenderValueAdapter().stringToGender(data[UserField.Gender.value]);
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
