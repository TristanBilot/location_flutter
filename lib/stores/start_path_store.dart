import 'dart:collection';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

/// Singleton class.
class StartPathStore {
  User _userInBuilding;
  User get user => _userInBuilding;

  bool ignoreUserCreation = false;

  StartPathStore._internal();
  static final StartPathStore _instance = StartPathStore._internal();

  factory StartPathStore() => _instance;

  void setUserGender(Gender gender) {
    _userInBuilding.gender = gender;
  }

  void setUserAge(int age) {
    _userInBuilding.age = age;
  }

  void setWantedGender(HashSet<Gender> genders) {
    _userInBuilding.settings.wantedGenders = genders.toList();
  }

  void setWantedAgeRange(List range) {
    _userInBuilding.settings.wantedAgeRange = range;
  }

  void setUser(User user) {
    _userInBuilding = user;
  }
}
