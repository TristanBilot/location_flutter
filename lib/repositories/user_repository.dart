import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/stores/database.dart';
import 'dart:io';
import 'image_repository.dart';
import '../models/user.dart';
import '../stores/store.dart';
import '../stores/conf.dart';
import '../stores/extensions.dart';

class UserRepository {
  static const RootKey = 'locations';

  Geoflutterfire _geo;
  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  UserRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
  }

  /// This method should only be used for the first log in
  /// with Facebook. It inserts a new user in the firestore
  /// with default values for settings and with Facebook
  /// data for name, email and use the current location.
  /// It also sent the user's picture to the storage.
  Future<void> insertUserForFirstConnection(User user) async {
    final GeoFirePoint geoPoint = Conf.testMode
        ? Store.parisGeoPosition
        : LocationCache().locationGeoPoint;
    await _firestore.collection(RootKey).doc(user.id).set(FirestoreUserEntry(
          user.firstName,
          user.lastName,
          user.gender,
          user.age,
          geoPoint,
          UserSettings.DefaultUserSettings,
        ).toFirestoreObject());
    File userPicture = await _imageRepo.urlToFile(user.pictureURL);
    return await _imageRepo.uploadFile(
        userPicture, user.id + Store.defaultProfilePictureExtension);
  }

  Future<void> updateUserLocation(User user, GeoFirePoint location) async {
    await _firestore.collection(RootKey).doc(user.id).update({
      UserField.Position.value: location.data,
    });
    // ++++ need catch error
  }

  /// Method used to add or update fields of the user's firestore.
  /// where `id` is the id of the user, `key`, one of the
  /// static keys in the repo and `value` a dynamic value;
  Future<void> updateUserValue(String id, UserField key, dynamic value) async {
    await _firestore.doc([RootKey, id].join('/')).update({
      key.value: value,
    });
  }

  /// Get a user from Firestore using its id.
  /// This method does not lookup to the cache if the
  /// id is already used.
  Future<User> getUserFromID(String id) async {
    Stopwatch stopwatch = new Stopwatch()..start();
    final document = _firestore.collection(RootKey).doc(id);
    final snapshot = await document.get();
    final user = await User.from(snapshot);
    print(
        'getUserFromID($id) fetched in ${stopwatch.elapsed.inMilliseconds}ms');
    return user;
  }

  /// Get a user from cache and repository, used when the chats page
  /// is reload when a message has arrived or active status changed.
  /// The heavy objects like images are fetched from cache and values
  /// which need refresh are fetch from firestore.
  /// `useCache` is a boolean which tell is yes or no, the cache should
  /// be used. By default, it is set to true.
  Future<User> getUserCachedFromID(
    String id, {
    bool useCache,
  }) async {
    if (!Database().keyExists(id)) {
      print('--- User not found in cache, fetching from Firestore');
      return getUserFromID(id);
    }
    Stopwatch stopwatch = new Stopwatch()..start();
    final document = _firestore.collection(RootKey).doc(id);
    final snapshot = await document.get();
    final user =
        await User.from(snapshot, withoutImageFetching: useCache ?? true);
    print(
        'getUserCachedFromID($id) fetched in ${stopwatch.elapsed.inMilliseconds}ms');
    return user;
  }

  /// Return true if the user id exists in the Firestore.
  Future<bool> usersExists(String id) async {
    try {
      var collectionRef = _firestore.collection(RootKey);
      var doc = await collectionRef.doc(id).get();
      return doc.exists;
    } catch (e) {
      throw e;
    }
  }
}
