import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user/user_blocked_info_fetcher.dart';
import 'package:location_project/repositories/user/user_likes_info_fetcher.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_info_fetcher.dart';
import 'package:location_project/repositories/user/user_views_info.fetcher.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';

enum UserField {
  // Root fields
  FirstName,
  LastName,
  Position,
  Age,
  Gender,
  DeviceTokens,
  PictureURLs,
  Bio,

  // Settings
  WantedGenders,
  WantedAgeRange,
  ShowMyProfile,
  ShowMyDistance,
  Connected,
  NotificationSettings,

  // Collections
  BlockedUserIDs,
  UserIDsWhoBlockedMe,
  ViewedUserIDs,
  UserIDsWhoWiewedMe,
  LikedUsers,
  UnlikedUsers,
  UsersWhoLikedMe,
}

class User extends HiveObject {
  String id;
  String email;
  String firstName;
  String lastName;
  List<double> coord; // [0]: latitude [1]: longitude
  BitmapDescriptor icon;
  List<String> pictureURLs;
  int distance;
  int age;
  Gender gender;
  UserSettings settings;
  List<String> deviceTokens;
  List<Image> pictures;
  String bio;

  // List<int> wantedAgeRange;
  // final List<String> wantedGenders;

  /// Collections
  List<String> blockedUserIDs;
  List<String> userIDsWhoBlockedMe;
  List<View> viewedUserIDs;
  List<View> userIDsWhoWiewedMe;
  List<String> unlikedUsers;
  List<String> likedUsers;

  User.public();

  User(
    this.email,
    this.firstName,
    this.lastName,
    this.coord,
    this.icon,
    this.pictureURLs,
    this.distance,
    this.age,
    this.gender,
    this.settings,
    this.blockedUserIDs,
    this.userIDsWhoBlockedMe,
    this.viewedUserIDs,
    this.userIDsWhoWiewedMe,
    this.deviceTokens,
    this.bio,
  ) {
    this.id = email;
  }

  bool getNotifSett(NotifType key) => settings.notificationSettings[key.value];

  bool get isMessageNotifEnable =>
      settings.notificationSettings[NotifType.Messages.value];
  bool get isChatNotifEnable =>
      settings.notificationSettings[NotifType.Chats.value];
  bool get isRequestNotifEnable =>
      settings.notificationSettings[NotifType.Requests.value];
  bool get isViewNotifEnable =>
      settings.notificationSettings[NotifType.Views.value];

  String get mainPictureURL => pictureURLs.first;

  User build({
    UserMandatoryInfo infos,
    UserBlockInfo blocks,
    UserViewsInfo views,
    UserLikesInfo likes,
    UserPicturesInfo pictures,
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
      this.deviceTokens = infos.deviceTokens;
      this.pictureURLs = infos.pictureURLs;
      this.bio = infos.bio;
    }
    if (views != null) {
      this.viewedUserIDs = views.viewedUserIDs;
      this.userIDsWhoWiewedMe = views.userIDsWhoWiewedMe;
    }
    if (likes != null) {
      this.unlikedUsers = likes.unlikedUsers;
      this.likedUsers = likes.likedUsers;
    }
    if (pictures != null) {
      this.pictures = pictures.pictures;
    }
    return this;
  }
}
