import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepository _repo;

  EditProfileCubit(this._repo) : super(EditProfileInitial());

  void didEditProfile(
    String bio,
    String name,
    int age,
    List<String> pictureURLs,
  ) {
    final id = UserStore().user.id;
    if (bio != UserStore().user.bio) {
      _repo.updateUserValue(id, UserField.Bio, bio);
      UserStore().user.bio = bio;
    }

    if (name != UserStore().user.firstName) {
      _repo.updateUserValue(id, UserField.FirstName, name);
      UserStore().user.firstName = name;
    }

    if (age != UserStore().user.age) {
      _repo.updateUserValue(id, UserField.Age, age);
      UserStore().user.age = age;
    }

    if (!_isSameArray(pictureURLs, UserStore().user.pictureURLs)) {
      _repo.updateUserValue(id, UserField.Bio, bio);
      UserStore().updatePictureURLs(pictureURLs);
    }
    emit(DidEditProfileState());
  }

  bool _isSameArray(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) if (a[i] != b[i]) return false;
    return true;
  }
}
