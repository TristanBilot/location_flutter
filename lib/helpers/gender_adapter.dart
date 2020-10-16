import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

class GenderAdapter {
  List<Gender> stringsToGenders(List<dynamic> strings) {
    return strings.map((e) {
      switch (e) {
        case 'Male':
          return Gender.Male;
        case 'Female':
          return Gender.Female;
        case 'Other':
          return Gender.Other;
      }
    }).toList();
  }

  List<String> gendersToStrings(List<Gender> genders) {
    return genders.map((e) => e.value).toList();
  }
}
