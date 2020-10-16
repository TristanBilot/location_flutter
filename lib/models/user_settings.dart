import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';

class UserSettings {
  static const bool DefaultShowMyProfile = true;
  static const bool DefaultShowMyDistance = true;
  static const List<int> DefaultWantedAgeRange = [18, 25];
  static final List<Gender> DefaultWantedGenders = [Gender.Other];

  static get DefaultUserSettings => UserSettings(DefaultWantedAgeRange,
      DefaultWantedGenders, DefaultShowMyProfile, DefaultShowMyDistance);

  List<int> wantedAgeRange;
  List<Gender> wantedGenders;
  bool showMyprofile;
  bool showMyDistance;

  UserSettings(
    this.wantedAgeRange,
    this.wantedGenders,
    this.showMyprofile,
    this.showMyDistance,
  );
}
