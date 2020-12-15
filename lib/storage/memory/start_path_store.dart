import 'dart:collection';
import 'dart:io';
import 'package:location_project/conf/store.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/image_repository.dart';

class StartPathStore {
  StartPathStore._internal();
  static final StartPathStore _instance = StartPathStore._internal();
  factory StartPathStore() => _instance;

  User _userInBuilding = User.public()
    ..settings = UserSettings.DefaultUserSettings;
  User get user => _userInBuilding;
  bool ignoreUserCreation = false;
  List<File> _userPictures;

  void setUserGender(Gender gender) {
    _userInBuilding.gender = gender;
  }

  void setUserAge(int age) {
    _userInBuilding.age = age;
  }

  void setWantedGender(HashSet<Gender> genders) {
    _userInBuilding.settings.wantedGenders = genders.toList();
  }

  void setWantedAgeRange(List range) {
    _userInBuilding.settings.wantedAgeRange = range;
  }

  void setUser(User user) {
    _userInBuilding = user;
  }

  /// TODO: changer quand on passer l'id à != mail
  void setEmailAndID(String id) {
    _userInBuilding.id = id;
    _userInBuilding.email = id;
  }

  void setName(String firstName) {
    _userInBuilding.firstName = firstName;
    _userInBuilding.lastName = "noName";
  }

  void setPictures(List<File> pictures) {
    _userPictures = pictures;
  }

  Future<void> uploadPictures() async {
    int count = 0;
    _userPictures.forEach((p) async => await ImageRepository().uploadFile(p,
        '${_userInBuilding.id}${Store.defaultProfilePictureExtension}${count == 0 ? "" : count}'));
  }
}
