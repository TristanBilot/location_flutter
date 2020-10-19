import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

class GenderAdapter {
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
