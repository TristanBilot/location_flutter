import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location_project/helpers/gender_adapter.dart';
import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import '../stores/extensions.dart';

/// Represents the User data stored in Firestore.
/// Used to add new users.
class FirestoreUserEntry implements FirestoreEntry {
  String firstName;
  String lastName;
  String gender;
  int age;
  dynamic geoPointData;
  bool showMyDistance;
  bool showMyProfile;
  List<int> wantedAgeRange;
  List<String> wantedGenders;

  FirestoreUserEntry(
    String firstName,
    String lastName,
    Gender gender,
    int age,
    GeoFirePoint geoPoint,
    UserSettings settings,
  ) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.gender = gender.value;
    this.age = age;
    this.geoPointData = geoPoint.data;
    this.showMyDistance = settings.showMyDistance;
    this.showMyProfile = settings.showMyprofile;
    this.wantedAgeRange = settings.wantedAgeRange;
    this.wantedGenders =
        GenderAdapter().gendersToStrings(settings.wantedGenders);
  }

  dynamic toFirestoreObject() {
    return {
      UserField.FirstName.value: firstName,
      UserField.LastName.value: lastName,
      UserField.Gender.value: gender,
      UserField.Age.value: age,
      UserField.Position.value: geoPointData,
      UserField.ShowMyDistance.value: showMyDistance,
      UserField.ShowMyProfile.value: showMyProfile,
      UserField.WantedAgeRange.value: wantedAgeRange,
      UserField.WantedGenders.value: wantedGenders,
    };
  }
}
