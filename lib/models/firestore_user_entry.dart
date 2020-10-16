import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location_project/helpers/gender_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/user_settings.dart';
import '../stores/extensions.dart';

/// Represents the User data stored in Firestore.
/// Used to add new users.
class FirestoreUserEntry {
  String firstName;
  String lastName;
  dynamic geoPointData;
  bool showMyDistance;
  bool showMyProfile;
  List<int> wantedAgeRange;
  List<String> wantedGenders;

  FirestoreUserEntry(
    String firstName,
    String lastName,
    GeoFirePoint geoPoint,
    UserSettings settings,
  ) {
    this.firstName = firstName;
    this.lastName = lastName;
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
      UserField.Position.value: geoPointData,
      UserField.ShowMyDistance.value: showMyDistance,
      UserField.ShowMyProfile.value: showMyProfile,
      UserField.WantedAgeRange.value: wantedAgeRange,
      UserField.WantedGenders.value: wantedGenders,
    };
  }
}
