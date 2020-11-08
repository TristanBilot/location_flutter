import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/helpers/gender_value_adapter.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/conf.dart';
import 'package:location_project/stores/database.dart';
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
  BlockedUserIDs,
  UserIDsWhoBlockedMe,
  ViewedUserIDs,
  UserIDsWhoWiewedMe,
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
  // Properties stored in the UserStore and fetched at start.
  List<String> blockedUserIDs;
  List<String> userIDsWhoBlockedMe;
  List<String> viewedUserIDs;
  List<String> userIDsWhoWiewedMe;

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
    this.blockedUserIDs,
    this.userIDsWhoBlockedMe,
    this.viewedUserIDs,
    this.userIDsWhoWiewedMe,
  ) {
    this.id = email;
  }

  /// Returns a User from a Firestore snapshot, the snaposhot
  /// is needed to get the id which is the email, then data()
  /// gives all the user's data.
  /// Parameters `withoutImageFetching` should be set to true only if
  /// a user will be fetched from a cached user that already
  /// has an image and thus we'll not fetch the image from firestore which take
  /// around one second per user.
  static Future<User> from(
    DocumentSnapshot snapshot, {
    bool withoutImageFetching = false,
  }) async {
    final id = snapshot.id;
    if (withoutImageFetching == true && !Database().keyExists(id)) {
      Logger().e(
          'from() if withoutImageFetching is true, $id should be find in the database cache.');
      return null;
    }
    Stopwatch stopwatch = Stopwatch()..start();
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

    final settings = UserSettings.fromFirestoreObject(data);
    final firstName = data[UserField.FirstName.value];
    final lastName = data[UserField.LastName.value];
    final coord = List<double>.from([geoPoint.latitude, geoPoint.longitude]);
    final gender =
        GenderValueAdapter().stringToGender(data[UserField.Gender.value]);
    final age = data[UserField.Age.value];
    int infoFetchingTime = stopwatch.elapsed.inMilliseconds;

    stopwatch = Stopwatch()..start();
    final blockedUserIDs = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.BlockedUserIDs);
    final userIDsWhoBlockedMe = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.UserIDsWhoBlockedMe);
    int blockedFetchingTime = stopwatch.elapsed.inMilliseconds;

    stopwatch = Stopwatch()..start();
    final viewedUserIDs = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.ViewedUserIDs);
    final userIDsWhoWiewedMe = await UserRepository()
        .getCollectionSnapshotAsStringArray(id, UserField.UserIDsWhoWiewedMe);
    int viewsFetchingTime = stopwatch.elapsed.inMilliseconds;

    // Use cache for images if withoutImageFetching is true.
    // This part take lot of time to fetch.
    stopwatch = Stopwatch()..start();
    BitmapDescriptor icon;
    dynamic pictureURL;
    if (withoutImageFetching == true) {
      User cachedUser = Database().getUser(id);
      icon = cachedUser.icon;
      pictureURL = cachedUser.pictureURL;
    } else {
      icon = await _imageRepo.fetchUserIcon(id);
      pictureURL = await _imageRepo.getPictureDownloadURL(id);
    }
    int imagesFetchingTime = stopwatch.elapsed.inMilliseconds;

    User user = User(
        id,
        firstName,
        lastName,
        coord,
        icon,
        pictureURL,
        distance,
        age,
        gender,
        settings,
        blockedUserIDs,
        userIDsWhoBlockedMe,
        viewedUserIDs,
        userIDsWhoWiewedMe);
    // Stores the user fetched from firestore to the Database cache.
    if (!withoutImageFetching) Database().putUser(user);
    int timeSum = infoFetchingTime +
        blockedFetchingTime +
        viewsFetchingTime +
        imagesFetchingTime;
    Logger().v('''=> $id from ${withoutImageFetching ? 'cache' : 'firestore'}
    infoFetchingTime: \t${infoFetchingTime}ms
    blockedFetchingTime: \t${blockedFetchingTime}ms
    viewsFetchingTime: \t${viewsFetchingTime}ms
    imagesFetchingTime: \t${imagesFetchingTime}ms\t${timeSum}ms''');
    return user;
  }

  /// Return the user corresponding to the id if it
  /// exists in the cache, or null.
  static User fromCache(String id) {
    if (!UserCache().userExists(id)) return null;
    return UserCache().getUser(id);
  }
}
