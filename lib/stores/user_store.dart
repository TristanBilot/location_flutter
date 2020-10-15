import 'package:flutter/cupertino.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

class UserStore extends ChangeNotifier {
  /* data get remotely from Firestore */
  User _user;
  List<int> _wantedAgeRange;
  List<Gender> _wantedGenders;
  bool _showMyprofile;
  bool _showMyDistance;

  /* data get from SharedPreferences */
  Language _language;

  /* repositories to get and set data */
  UserRepository _repo;
  UserLocalRepository _localRepo;

  User get user => _user;

  UserStore() {
    _repo = UserRepository();
    _localRepo = UserLocalRepository();
  }

  /* REMOVE LATER*/
  String idMock = 'bilot.tristan@hotmail.fr';

  static UserStore _instance;
  static UserStore get instance {
    return (_instance = _instance == null ? UserStore() : _instance);
  }

  Future<void> setLanguage(val) async {
    _language = val;
    _localRepo.setLanguage(val);
    notifyListeners();
  }

  Future<void> setWantedAgeRange(val) async {
    _wantedAgeRange = val;
    await _repo.updateUserSettingValue(
        idMock, UserFireStoreKey.WantedAgeRange, val);
    notifyListeners();
  }

  Future<void> setWantedGenders(val) async {
    _wantedGenders = val;
    await _repo.updateUserSettingValue(
        idMock, UserFireStoreKey.WantedGenders, val);
    notifyListeners();
  }

  Future<void> setShowMyprofile(val) async {
    _showMyprofile = val;
    await _repo.updateUserSettingValue(
        idMock, UserFireStoreKey.ShowMyProfile, val);
    notifyListeners();
  }

  Future<void> setShowMyDistance(val) async {
    _showMyDistance = val;
    await _repo.updateUserSettingValue(
        idMock, UserFireStoreKey.ShowMyDistance, val);
    notifyListeners();
  }

  Future<void> setUser(val) async {
    _user = val;
    await _repo.insertOrUpdateUser(val);
    notifyListeners();
  }
}
