import 'dart:collection';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

/// Singleton class.
class StartPathStore {
  // Step 1
  Gender _userGender;
  int _userAge;

  // Step 2
  HashSet<Gender> _wantedGenders;
  List<int> _wantedAgeRange; // [0]: min, [1]: max

  StartPathStore._internal();
  static final StartPathStore _instance = StartPathStore._internal();

  factory StartPathStore() {
    _instance._wantedGenders = HashSet();
    _instance._wantedAgeRange = List();
    return _instance;
  }

  void setUserGender(Gender gender) {
    _userGender = gender;
  }

  void setUserAge(int age) {
    _userAge = age;
  }

  void setWantedGender(HashSet<Gender> genders) {
    _wantedGenders = genders;
  }

  void setWantedAgeRange(List range) {
    _wantedAgeRange = range;
  }
}
