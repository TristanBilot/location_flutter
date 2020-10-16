import 'package:flutter/cupertino.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

class UserStore extends ChangeNotifier {
  /* data get remotely from Firestore */
  User _user;

  /* data get from SharedPreferences */
  Language _language;

  /* repositories to get and set data */
  UserRepository _repo;
  UserLocalRepository _localRepo;

  UserStore() {
    _repo = UserRepository();
  }

  /// Due to asynchronous calls when instanciating, this
  /// class need to load using await at the beginning
  /// of the app (usualy in the main). Should be called one.
  static Future<UserStore> get startingInstance async {
    _instance = UserStore();
    _instance._localRepo = await UserLocalRepository.startingInstance;
    await _instance._initStore();
    return _instance;
  }

  static UserStore _instance;
  static UserStore get instance => _instance;

  /// Init asynchronously the store at the launch of the
  /// app. Get the `id` from the local repo, then, get
  /// the user's data using the real repo.
  Future<void> _initStore() async {
    if (!_localRepo.isUserLoggedIn()) return;
    // throw Exception('_initStore(): No user logged in !');
    final id = _localRepo.getLoggedUserID();
    _user = await _repo.getUserFromID(id);
    _language = _localRepo.getAppLanguage();
  }

  bool isuserLoggedIn() {
    return _localRepo.isUserLoggedIn();
  }

  User get user => _user;

  /// These methods are used to update the data of the user
  /// in local with this store class and in Firestore using
  /// the repo or local repo for local infos.
  Future<void> setLanguage(Language val) async {
    _language = val;
    _localRepo.setLanguage(val);
    notifyListeners();
  }

  Future<void> setWantedAgeRange(List<int> val) async {
    _repo.getUserFromID(_user.email);
    _user.settings.wantedAgeRange = val;
    await _repo.updateUserValue(_user.email, UserField.WantedAgeRange, val);
    notifyListeners();
  }

  Future<void> setWantedGenders(List<Gender> val) async {
    _user.settings.wantedGenders = val;
    List<String> strings = val.map((e) => e.value).toList();
    await _repo.updateUserValue(_user.email, UserField.WantedGenders, strings);
    notifyListeners();
  }

  Future<void> setShowMyProfile(bool val) async {
    _user.settings.showMyprofile = val;
    await _repo.updateUserValue(_user.email, UserField.ShowMyProfile, val);
    notifyListeners();
  }

  Future<void> setShowMyDistance(bool val) async {
    _user.settings.showMyDistance = val;
    await _repo.updateUserValue(_user.email, UserField.ShowMyDistance, val);
    notifyListeners();
  }
}
