part of 'edit_profile_cubit.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object> get props => [];
}

class EditProfileInitial extends EditProfileState {}

class DidEditProfileState extends EditProfileState {
  @override
  List<Object> get props => [Random().nextDouble() * 1000];
}
