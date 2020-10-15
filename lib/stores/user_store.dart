import 'package:flutter/cupertino.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

class UserStore extends ChangeNotifier {
  /* data get remotely from Firestore */
  User _user;
  Gender _wantedGender;
  List<int> _wantedAgeRange;
  List<Gender> _wantedGenders;
  bool _showMyprofile;
  bool _showMyDistance;

  /* data get from SharedPreferences */
  Language _language;

  UserLocalRepository _localRepo;

  User get user => _user;
  Gender get wantedGender => _wantedGender;

  UserStore() {
    _localRepo = UserLocalRepository();
  }

  static UserStore _instance;
  static UserStore get instance {
    return (_instance = _instance == null ? UserStore() : _instance);
  }

  set setLanguage(val) {
    _language = val;
    _localRepo.setLanguage(val);
    notifyListeners();
  }

  set setWantedGender(val) {
    _wantedGenders = val;
    notifyListeners();
  }

  set setWantedAgeRange(val) {
    _wantedAgeRange = val;
    notifyListeners();
  }

  set setWantedGenders(val) {
    _wantedGenders = val;
    notifyListeners();
  }

  set setShowMyprofile(val) {
    _showMyprofile = val;
    notifyListeners();
  }

  set setShowMyDistance(val) {
    _showMyDistance = val;
    notifyListeners();
  }

  set setUser(val) {
    _user = val;
    notifyListeners();
  }
}
