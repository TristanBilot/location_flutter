import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

class GenderCircleIconFactory {
  List<GenderCircleIcon> icons;

  GenderCircleIconFactory() {
    icons = List();
  }

  List<GenderCircleIcon> makeGenderIcons(
    GenderIconController uniController,
    GenderMultiIconController multiController,
  ) {
    return [
      GenderCircleIcon(
        Gender.Male,
        '💆‍♂️',
        'Male',
        GenderCircleIconState(),
        uniController,
        multiController,
      ),
      GenderCircleIcon(
        Gender.Female,
        '🙋‍♀️',
        'Female',
        GenderCircleIconState(),
        uniController,
        multiController,
      ),
      GenderCircleIcon(
        Gender.Other,
        '🤷',
        'Other',
        GenderCircleIconState(),
        uniController,
        multiController,
      )
    ];
  }
}
