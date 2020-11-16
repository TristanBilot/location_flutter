import 'package:location_project/adapters/gender_value_adapter.dart';
import 'package:location_project/models/firestore_entry.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import '../stores/extensions.dart';

/// Represents the User data stored in Firestore.
/// Used to add new users.
class FirestoreUserEntry implements FirestoreEntry {
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final dynamic geoPointData;
  final bool showMyDistance;
  final bool showMyProfile;
  final bool connected;
  final List<int> wantedAgeRange;
  final List<String> wantedGenders;
  final List<String> blockedUserIDs;
  final List<String> userIDsWhoBlockedMe;
  final List<View> viewedUserIDs;
  final List<View> userIDsWhoWiewedMe;

  @override
  bool get stringify => null;

  @override
  List<Object> get props => [
        firstName,
        lastName,
        gender,
        age,
        geoPointData,
        showMyDistance,
        showMyProfile,
        connected,
        wantedAgeRange,
        wantedGenders,
        blockedUserIDs,
        userIDsWhoBlockedMe,
        viewedUserIDs,
        userIDsWhoWiewedMe,
      ];

  FirestoreUserEntry(
    this.firstName,
    this.lastName,
    Gender gender,
    this.age,
    geoPoint,
    settings,
    this.blockedUserIDs,
    this.userIDsWhoBlockedMe,
    this.viewedUserIDs,
    this.userIDsWhoWiewedMe,
  )   : this.gender = gender.value,
        this.geoPointData = geoPoint.data,
        this.showMyDistance = settings.showMyDistance,
        this.showMyProfile = settings.showMyprofile,
        this.connected = settings.connected,
        this.wantedAgeRange = settings.wantedAgeRange,
        this.wantedGenders =
            GenderValueAdapter().gendersToStrings(settings.wantedGenders);

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
      UserField.ViewedUserIDs.value: viewedUserIDs,
      UserField.UserIDsWhoWiewedMe.value: userIDsWhoWiewedMe,
    };
  }
}
