import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';

/// Manage all the data of the logged user.
/// Mainly the update of local and distant data
/// whenever there are modified. It should be
/// synchronized locally with the Firestore.
class UserStore {
  /* data get remotely from Firestore */
  User _user;
  User get user => _user;

  /* data get from SharedPreferences */
  Language _language;

  /* repositories to get and set data */
  UserRepository _repo = UserRepository();
  LocalStore _localRepo = LocalStore();

  UserStore._internal();
  static final UserStore _instance = UserStore._internal();

  factory UserStore() => _instance;

  /// Init asynchronously the store at the launch of the
  /// app. Get the `id` from the local repo, then, get
  /// the user's data using the real repo.
  /// All the data of the user are fetched at the start
  /// to be loaded in the local store and thus need less
  /// to call the distant firestore.
  Future<void> initAsynchronously({User fromUser}) async {
    if (!_localRepo.isUserLoggedIn() && fromUser == null) {
      print('User not connected. Store not initialized.');
      return;
    }
    final id = _localRepo.getLoggedUserID();
    _user = fromUser ??
        await _repo.fetchUser(
          id,
          withBlocks: true,
          withInfos: true,
          withViews: true,
          withLikes: true,
        );
    _language = _localRepo.getAppLanguage();
    setConnectedStatus(true);
  }

  bool isuserLoggedIn() {
    return _localRepo.isUserLoggedIn();
  }

  /// These methods are used to update the data of the user
  /// in local with this store class and in Firestore using
  /// the repo or local repo for local infos.
  Future<void> setLanguage(Language val) async {
    _language = val;
    _localRepo.setLanguage(val);
  }

  Future<void> setWantedAgeRange(List<int> val) async {
    _user.settings.wantedAgeRange = val;
    await _repo.updateUserValue(_user.id, UserField.WantedAgeRange, val);
  }

  Future<void> setWantedGenders(List<Gender> val) async {
    _user.settings.wantedGenders = val;
    List<String> strings = val.map((e) => e.value).toList();
    await _repo.updateUserValue(_user.id, UserField.WantedGenders, strings);
  }

  Future<void> setShowMyProfile(bool val) async {
    _user.settings.showMyprofile = val;
    await _repo.updateUserValue(_user.id, UserField.ShowMyProfile, val);
  }

  Future<void> setShowMyDistance(bool val) async {
    _user.settings.showMyDistance = val;
    await _repo.updateUserValue(_user.id, UserField.ShowMyDistance, val);
  }

  Future<void> setConnectedStatus(bool val) async {
    _user.settings.connected = val;
    await _repo.updateUserValue(_user.id, UserField.Connected, val);
  }

  /// Add a blocked user in the local store and in the firestore
  /// for both participants.
  Future<void> addBlockedUser(String blockedID) async {
    _user.blockedUserIDs.add(blockedID);
    await _repo.addOrReplaceToCollection(
        _user.id, UserField.BlockedUserIDs, blockedID);
    await _repo.addOrReplaceToCollection(
        blockedID, UserField.UserIDsWhoBlockedMe, _user.id);
  }

  /// Delete a blocked user from the local store and from the firestore
  /// for both participants.
  Future<void> deleteBlockedUser(String blockedID) async {
    _user.blockedUserIDs.remove(blockedID);
    await UserRepository().deleteCollectionSnapshot(
        _user.id, UserField.BlockedUserIDs, blockedID);
    await UserRepository().deleteCollectionSnapshot(
        blockedID, UserField.UserIDsWhoBlockedMe, _user.id);
  }

  /// Update locally the people to block on the map when
  /// an event "a user block me" is received in the UserRepository.
  /// Mandatory to update the data before refresh the map.
  void addLocalUserWhoBlockMe(String userIDWhoBlockedMe) {
    UserStore().user.userIDsWhoBlockedMe.add(userIDWhoBlockedMe);
  }

  void updateLocalUsersWhoBlockMe(List<String> userIDsWhoBlockedMe) {
    UserStore().user.userIDsWhoBlockedMe = userIDsWhoBlockedMe;
  }

  /// Add a new view in the local store and in the firestore for both
  /// participants.
  Future<void> addView(String viewedID) async {
    final viewed = View(viewedID, false);
    final view = View(_user.id, false);
    _user.viewedUserIDs.add(viewed);
    await _repo.addView(_user.id, UserField.ViewedUserIDs, viewed);
    await _repo.addView(viewedID, UserField.UserIDsWhoWiewedMe, view);
  }

  /// Delete a blocked user in the local store and in the firestore.
  /// Not used for the moment.
  @deprecated
  Future<void> deleteView(String viewedID) async {
    _user.viewedUserIDs.remove(viewedID);
    await _repo.deleteCollectionSnapshot(
        _user.id, UserField.ViewedUserIDs, viewedID);
    await _repo.deleteCollectionSnapshot(
        viewedID, UserField.UserIDsWhoWiewedMe, _user.id);
  }

  Future<void> toggleNotificationSettings(NotifType field) async {
    var messages = NotifType.Messages.value;
    var chats = NotifType.Chats.value;
    var requests = NotifType.Requests.value;
    var views = NotifType.Views.value;
    switch (field) {
      case NotifType.Messages:
        var toggle = !_user.settings.notificationSettings[messages];
        _user.settings.notificationSettings[messages] = toggle;
        _repo.updateNotificationSettings(_user.id, messages: toggle);
        break;
      case NotifType.Chats:
        var toggle = !_user.settings.notificationSettings[chats];
        _user.settings.notificationSettings[chats] = toggle;
        _repo.updateNotificationSettings(_user.id, chats: toggle);
        break;
      case NotifType.Requests:
        var toggle = !_user.settings.notificationSettings[requests];
        _user.settings.notificationSettings[requests] = toggle;
        _repo.updateNotificationSettings(_user.id, requests: toggle);
        break;
      case NotifType.Views:
        var toggle = !_user.settings.notificationSettings[views];
        _user.settings.notificationSettings[views] = toggle;
        _repo.updateNotificationSettings(_user.id, views: toggle);
        break;
      case NotifType.Unknown:
        Logger().w('toggleNotificationSettings(): unknown notif type');
        break;
    }
  }

  Future<void> addLike(String likedID) async {
    _user.likedUsers.add(likedID);
    await UserRepository()
        .addLikeField(_user.id, UserField.LikedUsers, likedID);
    await UserRepository()
        .addLikeField(likedID, UserField.UsersWhoLikedMe, _user.id);
  }

  Future<void> addUnlike(String unlikedID) async {
    _user.unlikedUsers.add(unlikedID);
    await UserRepository()
        .addLikeField(_user.id, UserField.UnlikedUsers, unlikedID);
  }

  Future<void> updatePictureURLs(List<String> pictureURLs) async {
    _user.pictureURLs = pictureURLs;
    await UserRepository()
        .updateUserValue(_user.id, UserField.PictureURLs, pictureURLs);
  }
}
