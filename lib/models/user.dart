import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user/user_blocked_info_fetcher.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user/user_views_info.fetcher.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';

part 'user.g.dart';

enum UserField {
  FirstName,
  LastName,
  Position,
  Age,
  Gender,

  WantedGenders,
  WantedAgeRange,
  ShowMyProfile,
  ShowMyDistance,
  Connected,
  BlockedUserIDs,
  UserIDsWhoBlockedMe,
  ViewedUserIDs,
  UserIDsWhoWiewedMe,
}

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String email;
  @HiveField(2)
  String firstName;
  @HiveField(3)
  String lastName;
  @HiveField(4)
  List<double> coord; // [0]: latitude [1]: longitude
  BitmapDescriptor icon;
  @HiveField(5)
  String pictureURL;
  @HiveField(6)
  int distance;
  @HiveField(7)
  int age;
  @HiveField(8)
  Gender gender;
  @HiveField(9)
  UserSettings settings;
  // Properties stored in the UserStore and fetched at start.
  List<String> blockedUserIDs;
  List<String> userIDsWhoBlockedMe;
  List<View> viewedUserIDs;
  List<View> userIDsWhoWiewedMe;

  User._();
  User.public();

  User(
    this.email,
    this.firstName,
    this.lastName,
    this.coord,
    this.icon,
    this.pictureURL,
    this.distance,
    this.age,
    this.gender,
    this.settings,
    this.blockedUserIDs,
    this.userIDsWhoBlockedMe,
    this.viewedUserIDs,
    this.userIDsWhoWiewedMe,
  ) {
    this.id = email;
  }

  User build({
    UserMandatoryInfo infos,
    UserPicturesInfo pictures,
    UserBlockInfo blocks,
    UserViewsInfo views,
  }) {
    if (blocks != null) {
      this.blockedUserIDs = blocks.blockedUserIDs;
      this.userIDsWhoBlockedMe = blocks.userIDsWhoBlockedMe;
    }
    if (infos != null) {
      this.id = infos.id;
      this.email = infos.email;
      this.firstName = infos.firstName;
      this.lastName = infos.lastName;
      this.age = infos.age;
      this.coord = infos.coord;
      this.distance = infos.distance;
      this.gender = infos.gender;
      this.settings = infos.settings;
    }
    if (views != null) {
      this.viewedUserIDs = views.viewedUserIDs;
      this.userIDsWhoWiewedMe = views.userIDsWhoWiewedMe;
    }
    if (pictures != null) {
      this.icon = pictures.icon;
      this.pictureURL = pictures.pictureURL;
    }
    return this;
  }
}
