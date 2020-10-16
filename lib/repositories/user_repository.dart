import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/caches/location_cache.dart';
import 'dart:io';
import 'image_repository.dart';
import '../models/user.dart';
import '../stores/store.dart';
import '../stores/conf.dart';
import '../stores/extensions.dart';

enum UserFireStoreKey {
  WantedGenders,
  WantedAgeRange,
  ShowMyProfile,
  ShowMyDistance,
}

class UserRepository {
  static const UserFireStoreRootKey = 'locations';

  Geoflutterfire _geo;
  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  UserRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
  }

  /*
  ^ FUNCTION
  * Insert a new user in the firestore if it does not exists
  * Change the values if the user already exists.
  * Insert the LastName, FirstName and position with the key 'email'
  * of the user, the picture is sent to the storage
  */
  Future<void> insertOrUpdateUser(User user) async {
    final GeoFirePoint geoPoint =
        Conf.testMode ? Store.parisGeoPosition : LocationCache.locationGeoPoint;
    await _firestore.collection(UserFireStoreRootKey).doc(user.email).set({
      UserField.LastName.value: user.lastName,
      UserField.FirstName.value: user.firstName,
      UserField.Position.value: geoPoint.data,
    });
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

  /// Method used to add or update fields in the settings
  /// area of the user's firestore.
  /// where `id` is the id of the user, `key`, one of the
  /// static keys in the repo and `value` a dynamic value;
  Future<void> updateUserSettingValue(
      String id, UserFireStoreKey key, dynamic value) async {
    await _firestore.doc([UserFireStoreRootKey, id].join('/')).update({
      key.value: value,
    });
  }

  // /*
  // ^ PRIVATE FUNCTION
  // * This method is only for testing purpose, to insert mock data to the firestore db
  // */
  // Future<void> putCarrieresDataset() async {
  //   // final locationData = await LocationController.getLocation();
  //   // GeoFirePoint geoPoint = _geo.point(
  //   //     latitude: locationData.latitude, longitude: locationData.longitude);

  //   GeoFirePoint carrieres =
  //       _geo.point(latitude: 48.91604, longitude: 2.179678);
  //   GeoFirePoint carrieres_2 =
  //       _geo.point(latitude: 48.916010, longitude: 2.179672);

  //   // _firestore.collection(UserFireStoreRootKey).doc('carrieres@hotmail.fr').set({
  //   //   UserField.FirstName.value: 'Tristan',
  //   //   UserField.LastName.value: 'Bilot',
  //   //   UserField.Position.value: geoPoint.data
  //   // });
  //   _firestore.collection(UserFireStoreRootKey).doc('carrieres2@hotmail.fr').set({
  //     UserField.FirstName.value: 'Kendall',
  //     UserField.LastName.value: 'Jenner',
  //     UserField.Position.value: carrieres.data
  //   });
  //   _firestore.collection(UserFireStoreRootKey).doc('carrieres3@hotmail.fr').set({
  //     UserField.FirstName.value: 'Camille',
  //     UserField.LastName.value: 'Houly',
  //     UserField.Position.value: carrieres_2.data
  //   });
  // }

  // Future<void> putParisDataSet() async {
  //   // final locationData = await LocationController.getLocation();
  //   // GeoFirePoint geoPoint = _geo.point(
  //   //     latitude: locationData.latitude, longitude: locationData.longitude);

  //   GeoFirePoint paris13 = _geo.point(latitude: 48.825194, longitude: 2.347420);
  //   GeoFirePoint paris13_2 =
  //       _geo.point(latitude: 48.824710, longitude: 2.348482);

  //   _firestore.collection(UserFireStoreRootKey).doc('camille@hotmail.fr').set({
  //     'email': 'kendall@hotmail.fr',
  //     'firstName': 'Kendall',
  //     'lastName': 'Jenner',
  //     UserField.Position.value: paris13.data
  //   });
  //   _firestore.collection(UserFireStoreRootKey).doc('bilot.tristan@hotmail.fr').set({
  //     'email': 'camille@hotmail.fr',
  //     'firstName': 'Camille',
  //     'lastName': 'Houly',
  //     UserField.Position.value: paris13_2.data
  //   });
  // }
}
