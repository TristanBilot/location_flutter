import 'package:flutter/material.dart';
import 'package:location_project/controllers/init_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/start_path_store.dart';

class LoginController {
  final BuildContext _context;
  AuthRepository _authRepository;

  LoginController(this._context) {
    _authRepository = AuthRepository();
  }

  void logIn() {
    _authRepository.logIn(
      _successUserExistsCompletion,
      _successUserDoesNotExistsCompletion,
      _cancelCompletion,
      _errorCompletion,
    );
  }

  /// Called when the Facebook login is a success and already exists.
  Future<void> _successUserExistsCompletion(String loggedID) async {
    final isLocationEnabled = await LocationController().isLocationEnabled();
    if (isLocationEnabled) {
      await InitController().initAfterLogin(loggedID);
      Navigator.of(_context).pushReplacementNamed(Routes.map.value);
    } else {
      if (UserLocalRepository().isLocationAlreadyAsked())
        Navigator.of(_context).pushReplacementNamed(Routes.map.value);
      else {
        StartPathStore().ignoreUserCreation = true;
        Navigator.of(_context)
            .pushReplacementNamed(Routes.startPathStep3.value);
      }
    }
  }

  /// When a user log in with Facebook for the first time,
  /// we need to set this new user to the `StartPathStore` in order to
  /// continue to build it during the StartPath.
  Future<void> _successUserDoesNotExistsCompletion(User newUser) async {
    StartPathStore().setUser(newUser);
    Navigator.of(_context).pushReplacementNamed(Routes.startPathStep1.value);
  }

  /// Called when the Facebook page has been cancelled.
  void _cancelCompletion() {
    print('Login cancelled by the user.');
  }

  /// Called when the Facebook login handle an error.
  void _errorCompletion(String error) {
    print('Something went wrong with the login process.\n'
        'Here\'s the error Facebook gave us: $error');
  }
}
