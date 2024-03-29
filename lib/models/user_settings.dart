import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';

class UserSettings {
  UserSettings.defaultConstructor();

  List<int> wantedAgeRange;
  List<Gender> wantedGenders;
  bool showMyprofile;
  bool showMyDistance;
  bool connected;
  Map<String, bool> notificationSettings;

  UserSettings(
    this.wantedAgeRange,
    this.wantedGenders,
    this.showMyprofile,
    this.showMyDistance,
    this.connected,
    this.notificationSettings,
  );

  static final DefaultUserSettings = UserSettings(
    DefaultWantedAgeRange,
    DefaultWantedGenders,
    DefaultShowMyProfile,
    DefaultShowMyDistance,
    DefaultConnected,
    DefaultNotificationSettings,
  );

  static const bool DefaultShowMyProfile = true;
  static const bool DefaultShowMyDistance = true;
  static const bool DefaultConnected = true;
  static const List<int> DefaultWantedAgeRange = [18, 25];
  static final List<Gender> DefaultWantedGenders = [
    Gender.Other,
    Gender.Female,
    Gender.Male
  ];
  static final Map<String, bool> DefaultNotificationSettings = {
    NotifType.Message.value: true,
    NotifType.Match.value: true,
    NotifType.View.value: true,
    NotifType.Like.value: true,
  };

  static UserSettings fromFirestoreObject(dynamic data) {
    final wantedAgeRange = List<int>.from(data[UserField.WantedAgeRange.value]);
    final wantedGenders = GenderValueAdapter().stringsToGenders(
      List<String>.from(data[UserField.WantedGenders.value]),
    );
    final showMyProfile = data[UserField.ShowMyProfile.value] as bool;
    final showMyDistance = data[UserField.ShowMyDistance.value] as bool;
    final connected = data[UserField.Connected.value] as bool;
    final notificationSettings =
        (data[UserField.NotificationSettings.value] as Map)
            ?.cast<String, bool>();

    return UserSettings(
      wantedAgeRange,
      wantedGenders,
      showMyProfile,
      showMyDistance,
      connected,
      notificationSettings,
    );
  }
}
