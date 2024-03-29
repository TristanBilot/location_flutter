import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/adapters/stream_adapter.dart';
import 'package:location_project/conf/conf.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/firestore_user_entry.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user/user_blocked_info_fetcher.dart';
import 'package:location_project/repositories/user/user_likes_info_fetcher.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_info_fetcher.dart';
import 'package:location_project/repositories/user/user_views_info.fetcher.dart';
import 'package:location_project/storage/memory/location_cache.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/swipe_card/models/like_field.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'dart:io';
import 'image_repository.dart';
import '../models/user.dart';

class UserRepository {
  static const RootKey = 'locations';

  FirebaseFirestore _firestore;
  ImageRepository _imageRepo;

  /// Fetchers.
  UserMandatoryInfoFetcher _mandatoryInfoFetcher;
  UserBlockInfoFetcher _blockInfoFetcher;
  UserViewsInfoFetcher _viewsInfoFetcher;
  UserPicturesInfoFetcher _picturesInfoFetcher;
  UserLikesInfoFetcher _likesInfoFetcher;

  UserRepository() {
    _firestore = FirebaseFirestore.instance;
    _imageRepo = ImageRepository();
    _mandatoryInfoFetcher = UserMandatoryInfoFetcher();
    _blockInfoFetcher = UserBlockInfoFetcher();
    _viewsInfoFetcher = UserViewsInfoFetcher();
    _picturesInfoFetcher = UserPicturesInfoFetcher();
    _likesInfoFetcher = UserLikesInfoFetcher();
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
          user.deviceTokens,
          UserSettings.DefaultNotificationSettings,
          user.pictureURLs,
          user.bio,
        ).toFirestoreObject());
    File userPicture = await _imageRepo.urlToFile(user.mainPictureURL);
    await _imageRepo.uploadFile(
        user.id, userPicture, user.id + Store.defaultProfilePictureExtension);
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
  Stream<QuerySnapshot> getUserWhoBlockedMeStream(String id) {
    return _firestore
        .collection(RootKey)
        .doc(id)
        .collection(UserField.UserIDsWhoBlockedMe.value)
        .snapshots();
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
    // bool useDatabase = false,
    DocumentSnapshot fromSnapshot,
    bool withBlocks = false,
    bool withPictures = false,
    bool withInfos = false,
    bool withViews = false,
    bool withLikes = false,
  }) async {
    // if (useCache && useDatabase)
    //   Logger().e(
    //       'fetchUser(): useCache and useDatabase should not be used together');
    // if (useDatabase) {
    //   if (!UserDatabase().keyExists(id)) {
    //     Logger().w('useDatabase true but user not found in database.');
    //     return fetchUser(id,
    //         fromSnapshot: fromSnapshot,
    //         withBlocks: withBlocks,
    //         withPictures: withPictures,
    //         withInfos: withInfos,
    //         withViews: withViews,
    //         withLikes: withLikes);
    //   }
    //   return UserDatabase().getUser(id);
    // }
    if (useCache) {
      if (!MemoryStore().userExists(id)) {
        Logger().w('useCache true but user not found in cache.');
        return fetchUser(id,
            fromSnapshot: fromSnapshot,
            withBlocks: withBlocks,
            withPictures: withPictures,
            withInfos: withInfos,
            withViews: withViews,
            withLikes: withLikes);
      }
      return MemoryStore().getUser(id);
    }

    User user = await _fetchUserWithSpecificInfos(id,
        withBlocks: withBlocks,
        withInfos: withInfos,
        withPictures: withPictures,
        withViews: withViews,
        withLikes: withLikes);

    // Stores the user fetched from firestore to the UserDatabase cache.
    // UserDatabase().putUser(user);
    return user;
  }

  Future<User> _fetchUserWithSpecificInfos(
    String id, {
    DocumentSnapshot snapshot,
    bool withBlocks,
    bool withPictures,
    bool withInfos,
    bool withViews,
    bool withLikes,
  }) async {
    User user = User.public();

    UserMandatoryInfo userInfos;
    UserPicturesInfo userPictures;
    UserBlockInfo userBlocks;
    UserViewsInfo userViews;
    UserLikesInfo userLikes;

    if (withInfos) {
      userInfos = snapshot != null
          ? _mandatoryInfoFetcher.fetchFromSnapshot(snapshot)
          : await _mandatoryInfoFetcher.fetch(id);
      user.build(infos: userInfos);
    }
    if (withPictures) {
      if (user.pictureURLs == null || user.pictureURLs.isEmpty) {
        Logger().e('No pictures URL found in fetch()');
      } else {
        userPictures = await _picturesInfoFetcher.fetch(user.pictureURLs);
        user.build(pictures: userPictures);
      }
    }
    if (withBlocks) {
      userBlocks = await _blockInfoFetcher.fetch(id);
      user.build(blocks: userBlocks);
    }
    if (withViews) {
      userViews = await _viewsInfoFetcher.fetch(id);
      user.build(views: userViews);
    }
    if (withLikes) {
      userLikes = await _likesInfoFetcher.fetch(id);
      user.build(likes: userLikes);
    }
    Logger().logUserInfo(id,
        blocks: userBlocks,
        views: userViews,
        infos: userInfos,
        pictures: userPictures,
        likes: userLikes);
    return user;
  }

  Future<DocumentSnapshot> fetchUserDocumentSnapshot(String id) async {
    return _firestore.collection(RootKey).doc(id).get();
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
    return _firestore.collection(RootKey).doc(id).snapshots().map(
        (snapshot) => UserMandatoryInfoFetcher().fetchFromSnapshot(snapshot));
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
        .collection(UserField.UserIDsWhoViewedMe.value)
        .snapshots()
        .transform(StreamAdapter().mapToListOfEntries<View>());
  }

  Future<List<View>> fetchViewsAsList(String id) async {
    return (await _firestore
            .collection(RootKey)
            .doc(id)
            .collection(UserField.UserIDsWhoViewedMe.value)
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

  Future<void> addDeviceID(String id, String deviceID) async {
    _firestore.collection(RootKey).doc(id).update({
      UserField.DeviceTokens.value: FieldValue.arrayUnion([deviceID]),
    });
  }

  Future<void> removeDeviceID(String id, String deviceID) async {
    _firestore.collection(RootKey).doc(id).update({
      UserField.DeviceTokens.value: FieldValue.arrayRemove([deviceID]),
    });
  }

  /// If the user uninstall the app, we can't handle properly it so the device ID
  /// still in the user's device IDs, so at the next login from another account,
  /// after the app has been reinstalled, we need to delete the obsolete existing device ID
  /// from the previous account used when that app had been uninstalled.
  ///
  /// Edit: Normally not necessary to use, because of automatic regeneration of
  /// the device ID at each app reinstallation
  @deprecated
  Future<void> removeDuplicateExistingDeviceID(String deviceID) async {
    List<String> userIDsToUpdate = List();
    await _firestore
        .collection(RootKey)
        .where(UserField.DeviceTokens.value, arrayContains: deviceID)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) userIDsToUpdate.add(doc.id);
    });
    userIDsToUpdate.forEach((id) => removeDeviceID(id, deviceID));
  }

  Future<void> updateNotificationSettings(
    String id, {
    bool message,
    bool match,
    bool view,
    bool like,
  }) async {
    if (message == null && match == null && view == null && like == null)
      return;
    String key = '${UserField.NotificationSettings.value}.';
    bool value;
    if (message != null) {
      key += NotifType.Message.value;
      value = message;
    } else if (match != null) {
      key += NotifType.Match.value;
      value = match;
    } else if (view != null) {
      key += NotifType.View.value;
      value = view;
    } else if (like != null) {
      key += NotifType.Like.value;
      value = like;
    }
    _firestore.collection(RootKey).doc(id).update({key: value});
  }

  Future<void> addLikeField(String id, UserField field, String likeID) async {
    await _firestore
        .collection(RootKey)
        .doc(id)
        .collection(field.value)
        .doc(likeID)
        .set({LikeField.Time.value: Message.Time});
  }
}
