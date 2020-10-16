import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/user_settings.dart';
import 'dart:io';
import 'image_repository.dart';
import '../models/user.dart';
import '../stores/store.dart';
import '../stores/conf.dart';
import '../stores/extensions.dart';

class UserRepository {
  static const UserFireStoreRootKey = 'locations';

  Geoflutterfire _geo;
  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  UserRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
    // putCarrieresDataset();
    // putParisDataSet();
  }

  /// This method should only be used for the first log in
  /// with Facebook. It inserts a new user in the firestore
  /// with default values for settings and with Facebook
  /// data for name, email and use the current location.
  /// It also sent the user's picture to the storage.
  Future<void> insertUserForFirstConnection(User user) async {
    final GeoFirePoint geoPoint =
        Conf.testMode ? Store.parisGeoPosition : LocationCache.locationGeoPoint;
    await _firestore
        .collection(UserFireStoreRootKey)
        .doc(user.email)
        .set(FirestoreUserEntry(
          user.firstName,
          user.lastName,
          geoPoint,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
    File userPicture = await _imageRepo.urlToFile(user.pictureURL);
    return await _imageRepo.uploadFile(
        userPicture, user.email + Store.defaultProfilePictureExtension);
  }

  Future<void> updateUserLocation(User user, GeoFirePoint location) async {
    await _firestore.collection(UserFireStoreRootKey).doc(user.email).update({
      UserField.Position.value: location.data,
    });
    // ++++ need catch error
  }

  /// Method used to add or update fields of the user's firestore.
  /// where `id` is the id of the user, `key`, one of the
  /// static keys in the repo and `value` a dynamic value;
  Future<void> updateUserValue(String id, UserField key, dynamic value) async {
    await _firestore.doc([UserFireStoreRootKey, id].join('/')).update({
      key.value: value,
    });
  }

  /// Get a user from Firestore using its id.
  /// This method does not lookup to the cache if the
  /// id is already used.
  Future<User> getUserFromID(String id) async {
    var document = _firestore.collection(UserFireStoreRootKey).doc(id);
    var snapshot = await document.get();
    return User.from(snapshot);
  }

  Future<bool> usersExists(String id) async {
    try {
      var collectionRef = _firestore.collection(UserFireStoreRootKey);
      var doc = await collectionRef.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }

  /*
  ^ PRIVATE FUNCTION
  * This method is only for testing purpose, to insert mock data to the firestore db
  */
  Future<void> putCarrieresDataset() async {
    final locationData = await LocationController().getLocation();
    GeoFirePoint geoPoint = _geo.point(
        latitude: locationData.latitude, longitude: locationData.longitude);

    GeoFirePoint carrieres = _geo.point(latitude: 48.9162, longitude: 2.179672);
    GeoFirePoint carrieres_2 =
        _geo.point(latitude: 48.9163, longitude: 2.179678);

    _firestore
        .collection(UserFireStoreRootKey)
        .doc('carrieres@hotmail.fr')
        .set(FirestoreUserEntry(
          'Tristan',
          'Bilot',
          geoPoint,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
    _firestore
        .collection(UserFireStoreRootKey)
        .doc('carrieres2@hotmail.fr')
        .set(FirestoreUserEntry(
          'Kendall',
          'Jenner',
          carrieres,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
    _firestore
        .collection(UserFireStoreRootKey)
        .doc('carrieres3@hotmail.fr')
        .set(FirestoreUserEntry(
          'Camille',
          'Mouly',
          carrieres_2,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
  }

  Future<void> putParisDataSet() async {
    // final locationData = await LocationController.getLocation();
    // GeoFirePoint geoPoint = _geo.point(
    //     latitude: locationData.latitude, longitude: locationData.longitude);

    GeoFirePoint paris13 = _geo.point(latitude: 48.825194, longitude: 2.34742);
    GeoFirePoint paris13_2 =
        _geo.point(latitude: 48.82471, longitude: 2.348482);
    GeoFirePoint paris13_3 = _geo.point(latitude: 48.8247, longitude: 2.3484);

    _firestore
        .collection(UserFireStoreRootKey)
        .doc('camille@hotmail.fr')
        .set(FirestoreUserEntry(
          'Camille',
          'Mouly',
          paris13,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());

    _firestore
        .collection(UserFireStoreRootKey)
        .doc('tristan.location.test@gmail.com')
        .set(FirestoreUserEntry(
          'Camille',
          'Mouly',
          paris13_2,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());

    _firestore
        .collection(UserFireStoreRootKey)
        .doc('kendall@hotmail.fr')
        .set(FirestoreUserEntry(
          'Camille',
          'Mouly',
          paris13_3,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
  }
}
