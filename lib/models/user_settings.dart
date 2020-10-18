import 'package:location_project/helpers/gender_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

class UserSettings {
  static const bool DefaultShowMyProfile = true;
  static const bool DefaultShowMyDistance = true;
  static const bool DefaultConnected = true;
  static const List<int> DefaultWantedAgeRange = [18, 25];
  static final List<Gender> DefaultWantedGenders = [Gender.Other];

  List<int> wantedAgeRange;
  List<Gender> wantedGenders;
  bool showMyprofile;
  bool showMyDistance;
  bool connected;

  UserSettings(
    this.wantedAgeRange,
    this.wantedGenders,
    this.showMyprofile,
    this.showMyDistance,
    this.connected,
  );

  static get DefaultUserSettings => UserSettings(
        DefaultWantedAgeRange,
        DefaultWantedGenders,
        DefaultShowMyProfile,
        DefaultShowMyDistance,
        DefaultConnected,
      );

  static UserSettings fromFirestoreObject(dynamic data) {
    final wantedAgeRange = List<int>.from(data[UserField.WantedAgeRange.value]);
    final wantedGenders = GenderAdapter().stringsToGenders(
      List<String>.from(data[UserField.WantedGenders.value]),
    );
    final showMyProfile = data[UserField.ShowMyProfile.value] as bool;
    final showMyDistance = data[UserField.ShowMyDistance.value] as bool;
    final connected = data[UserField.Connected.value] as bool;

    return UserSettings(
      wantedAgeRange,
      wantedGenders,
      showMyProfile,
      showMyDistance,
      connected,
    );
  }
}
