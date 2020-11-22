import 'package:location_project/models/gender.dart';
import 'package:location_project/conf/extensions.dart';

class GenderValueAdapter {
  Gender stringToGender(String string) {
    switch (string) {
      case 'Male':
        return Gender.Male;
      case 'Female':
        return Gender.Female;
      case 'Other':
        return Gender.Other;
      default:
        return null;
    }
  }

  List<Gender> stringsToGenders(List<String> strings) {
    return strings.map((e) => stringToGender(e)).toList();
  }

  List<String> gendersToStrings(List<Gender> genders) {
    return genders.map((e) => e.value).toList();
  }
}
