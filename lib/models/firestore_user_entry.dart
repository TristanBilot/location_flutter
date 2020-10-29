import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location_project/helpers/gender_value_adapter.dart';
import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/models/gender.dart';
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
  bool connected;
  List<int> wantedAgeRange;
  List<String> wantedGenders;
  List<String> blockedUserIDs;
  List<String> userIDsWhoBlockedMe;

  FirestoreUserEntry(
    String firstName,
    String lastName,
    Gender gender,
    int age,
    GeoFirePoint geoPoint,
    UserSettings settings,
    List<String> blockedUserIDs,
    List<String> userIDsWhoBlockedMe,
  ) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.gender = gender.value;
    this.age = age;
    this.geoPointData = geoPoint.data;
    this.showMyDistance = settings.showMyDistance;
    this.showMyProfile = settings.showMyprofile;
    this.connected = settings.connected;
    this.wantedAgeRange = settings.wantedAgeRange;
    this.wantedGenders =
        GenderValueAdapter().gendersToStrings(settings.wantedGenders);
    this.blockedUserIDs = blockedUserIDs;
    this.userIDsWhoBlockedMe = userIDsWhoBlockedMe;
  }

  dynamic toFirestoreObject() {
    return {
      UserField.FirstName.value: firstName,
      UserField.LastName.value: lastName,
      UserField.Gender.value: gender,
      UserField.Age.value: age,
      UserField.Position.value: geoPointData,
      UserField.Connected.value: connected,
      UserField.ShowMyDistance.value: showMyDistance,
      UserField.ShowMyProfile.value: showMyProfile,
      UserField.WantedAgeRange.value: wantedAgeRange,
      UserField.WantedGenders.value: wantedGenders,
    };
  }
}
