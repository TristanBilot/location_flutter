import 'dart:collection';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

class StartPathStore {
  // Step 1
  Gender _userGender;
  int _userAge;

  // Step 2
  HashSet<Gender> _wantedGenders;
  List<int> _wantedAgeRange; // [0]: min, [1]: max

  static StartPathStore _instance;
  static StartPathStore get instance {
    return (_instance = _instance == null ? StartPathStore() : _instance);
  }

  StartPathStore() {
    _wantedGenders = HashSet();
    _wantedAgeRange = List();
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
