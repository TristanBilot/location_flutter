import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/stream_adapter.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/caches/user_cache.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user/user_blocked_info_fetcher.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user/user_views_info.fetcher.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
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

  /// Fetchers.
  UserMandatoryInfoFetcher _mandatoryInfoFetcher;
  UserBlockInfoFetcher _blockInfoFetcher;
  UserViewsInfoFetcher _viewsInfoFetcher;
  UserPicturesInfoFetcher _picturesInfoFetcher;

  UserRepository() {
    _geo = Geoflutterfire();
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
    _mandatoryInfoFetcher = UserMandatoryInfoFetcher();
    _blockInfoFetcher = UserBlockInfoFetcher();
    _viewsInfoFetcher = UserViewsInfoFetcher();
    _picturesInfoFetcher = UserPicturesInfoFetcher();
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
            user.blockedUserIDs,
            user.userIDsWhoBlockedMe,
            user.viewedUserIDs,
            user.userIDsWhoWiewedMe)
        .toFirestoreObject());
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

  /// Append a value in a collection at the root field.
  /// If the value already exists, it will be replaced by
  /// the new value.
  Future<void> addOrReplaceToCollection(
      String id, UserField field, dynamic value) async {
    await _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .doc(value)
        .set({});
  }

  /// Handle when the `UserIDsWhoBlockedMe` entry is modified,
  /// so when a block user ID is added to this entry, the map
  /// will be refreshed so that the block user not see the user who
  /// blocked him.
  /// The user store is updated before refreshing the area to
  /// not diplay this user.
  Future<void> listenToUsersWhoBlockMeEvents(
      String id, Function fetchAreaFromMap) async {
    _firestore
        .collection(RootKey)
        .doc(id)
        .collection(UserField.UserIDsWhoBlockedMe.value)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty || event.docs.first.data().keys.isEmpty) return;
      final userIDToBlock = event.docs.first.data().keys.first;
      UserStore().addLocalUserWhoBlockMe(userIDToBlock);
      fetchAreaFromMap();
    });
  }

  /// Returns a snapshot of documents in the root of the user Field.
  Future<QuerySnapshot> getCollectionSnapshot(
      String id, UserField field) async {
    return _firestore.collection(RootKey).doc(id).collection(field.value).get();
  }

  /// Returns a snapshot of documents in the root of the user Field as
  /// a list of strings.
  Future<List<String>> getCollectionSnapshotAsStringArray(
      String id, UserField field) async {
    return List<String>.from((await getCollectionSnapshot(id, field))
        .docs
        .map((doc) => doc.id)
        .toList());
  }

  /// Delete a document designed by `fieldID` in the field.
  Future<void> deleteCollectionSnapshot(
      String id, UserField field, String fieldID) async {
    _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .doc(fieldID)
        .delete();
  }

  Future<void> deleteCollection(String chatID, UserField field) async {
    _firestore
        .collection(RootKey)
        .doc(chatID)
        .collection(field.value)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) doc.reference.delete();
    });
  }

  Future<User> fetchUser(
    String id, {
    bool useCache = false,
    bool useDatabase = false,
    DocumentSnapshot fromSnapshot,
    bool withBlocks = true,
    bool withPictures = true,
    bool withInfos = true,
    bool withViews = true,
  }) async {
    if (useCache && useDatabase)
      Logger().e(
          'fetchUser(): useCache and useDatabase should not be used together');
    if (useDatabase) {
      if (!Database().keyExists(id)) {
        Logger().w('useDatabase true but user not found in database.');
        return fetchUser(id,
            fromSnapshot: fromSnapshot,
            withBlocks: withBlocks,
            withPictures: withPictures,
            withInfos: withInfos,
            withViews: withViews);
      }
      return Database().getUser(id);
    }
    if (useCache) {
      if (!UserCache().userExists(id)) {
        Logger().w('useCache true but user not found in cache.');
        return fetchUser(id,
            fromSnapshot: fromSnapshot,
            withBlocks: withBlocks,
            withPictures: withPictures,
            withInfos: withInfos,
            withViews: withViews);
      }
      return UserCache().getUser(id);
    }

    User user = await _fetchUserWithSpecificInfos(id,
        withBlocks: withBlocks,
        withInfos: withInfos,
        withPictures: withPictures,
        withViews: withViews);

    // Stores the user fetched from firestore to the Database cache.
    Database().putUser(user);
    return user;
  }

  Future<User> _fetchUserWithSpecificInfos(
    String id, {
    DocumentSnapshot fromSnapshot,
    bool withBlocks,
    bool withPictures,
    bool withInfos,
    bool withViews,
  }) async {
    final snapshot =
        fromSnapshot ?? await _firestore.collection(RootKey).doc(id).get();
    User user = User.public();

    UserMandatoryInfo userInfos;
    UserPicturesInfo userPictures;
    UserBlockInfo userBlocks;
    UserViewsInfo userViews;

    if (withInfos) {
      userInfos = await _mandatoryInfoFetcher.fetch(snapshot);
      user.build(infos: userInfos);
    }
    if (withPictures) {
      userPictures = await _picturesInfoFetcher.fetch(id);
      user.build(pictures: userPictures);
    }
    if (withBlocks) {
      userBlocks = await _blockInfoFetcher.fetch(id);
      user.build(blocks: userBlocks);
    }
    if (withViews) {
      userViews = await _viewsInfoFetcher.fetch(id);
      user.build(views: userViews);
    }
    Logger().logUserInfo(id,
        blocks: userBlocks,
        views: userViews,
        infos: userInfos,
        pictures: userPictures);
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

  Stream<UserMandatoryInfo> fetchUserInfoStream(String id) {
    return _firestore
        .collection(RootKey)
        .doc(id)
        .snapshots()
        .map((snapshot) => UserMandatoryInfoFetcher().fetch(snapshot));
  }

  Future<void> addView(String id, UserField field, View view) async {
    final ref = _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .doc(view.id);
    final viewExists = (await ref.get()).exists;
    if (!viewExists) ref.set(view.toFirestoreObject());
  }

  Future<void> updateView(
      String id, UserField field, View view, bool isViewed) async {
    final newView = View(view.id, isViewed);
    _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .doc(view.id)
        .set(newView.toFirestoreObject());
  }

  Stream<List<View>> fetchViewsAsStream(String id) {
    return _firestore
        .collection(RootKey)
        .doc(id)
        .collection(UserField.UserIDsWhoWiewedMe.value)
        .snapshots()
        .transform(StreamAdapter().mapToListOfEntries<View>());
  }

  Future<List<View>> fetchViewsAsList(String id) async {
    return (await _firestore
            .collection(RootKey)
            .doc(id)
            .collection(UserField.UserIDsWhoWiewedMe.value)
            .get())
        .docs
        .map((view) => View.fromFirestoreObject(view.data()))
        .toList();
  }

  /// Returns a stream of list of `IDs` of documents of a collection
  /// at root entry.
  Stream<List<String>> getCollectionListOfIDs(String id, UserField field) {
    return _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .snapshots()
        .map((snapshot) =>
            List<String>.from(snapshot.docs.map((doc) => doc.id).toList()));
  }
}
