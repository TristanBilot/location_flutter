import 'package:flutter/cupertino.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import '../stores/extensions.dart';

/// Manage all the data of the logged user.
/// Mainly the update of local and distant data
/// whenever there are modified. It should be
/// synchronized locally with the Firestore.
class UserStore extends ChangeNotifier {
  /* data get remotely from Firestore */
  User _user;
  User get user => _user;

  /* data get from SharedPreferences */
  Language _language;

  /* repositories to get and set data */
  UserRepository _repo = UserRepository();
  UserLocalRepository _localRepo = UserLocalRepository();

  UserStore._internal();
  static final UserStore _instance = UserStore._internal();

  factory UserStore() => _instance;

  /// Init asynchronously the store at the launch of the
  /// app. Get the `id` from the local repo, then, get
  /// the user's data using the real repo.
  /// All the data of the user are fetched at the start
  /// to be loaded in the local store and thus need less
  /// to call the distant firestore.
  Future<void> initAsynchronously() async {
    if (!_localRepo.isUserLoggedIn()) {
      print('User not connected. Store not initialized.');
      return;
    }
    final id = _localRepo.getLoggedUserID();
    _user = await _repo.fetchUser(id);
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
    notifyListeners();
  }

  Future<void> setWantedAgeRange(List<int> val) async {
    _user.settings.wantedAgeRange = val;
    await _repo.updateUserValue(_user.id, UserField.WantedAgeRange, val);
    notifyListeners();
  }

  Future<void> setWantedGenders(List<Gender> val) async {
    _user.settings.wantedGenders = val;
    List<String> strings = val.map((e) => e.value).toList();
    await _repo.updateUserValue(_user.id, UserField.WantedGenders, strings);
    notifyListeners();
  }

  Future<void> setShowMyProfile(bool val) async {
    _user.settings.showMyprofile = val;
    await _repo.updateUserValue(_user.id, UserField.ShowMyProfile, val);
    notifyListeners();
  }

  Future<void> setShowMyDistance(bool val) async {
    _user.settings.showMyDistance = val;
    await _repo.updateUserValue(_user.id, UserField.ShowMyDistance, val);
    notifyListeners();
  }

  Future<void> setConnectedStatus(bool val) async {
    _user.settings.connected = val;
    await _repo.updateUserValue(_user.id, UserField.Connected, val);
    notifyListeners();
  }

  /// Add a blocked user in the local store and in the firestore
  /// for both participants.
  Future<void> addBlockedUser(String blockedID) async {
    _user.blockedUserIDs.add(blockedID);
    await _repo.addOrReplaceToCollection(
        _user.id, UserField.BlockedUserIDs, blockedID);
    await _repo.addOrReplaceToCollection(
        blockedID, UserField.UserIDsWhoBlockedMe, _user.id);
    notifyListeners();
  }

  /// Delete a blocked user from the local store and from the firestore
  /// for both participants.
  Future<void> deleteBlockedUser(String blockedID) async {
    _user.blockedUserIDs.remove(blockedID);
    await UserRepository().deleteCollectionSnapshot(
        _user.id, UserField.BlockedUserIDs, blockedID);
    await UserRepository().deleteCollectionSnapshot(
        blockedID, UserField.UserIDsWhoBlockedMe, _user.id);
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
  }
}
