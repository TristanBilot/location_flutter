import 'package:flutter/material.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/user_store.dart';

class LoginController {
  final BuildContext _context;
  AuthRepository _authRepository;

  LoginController(this._context) {
    _authRepository = AuthRepository();
  }

  void logIn() {
    _authRepository.logIn(
      _successCompletion,
      _cancelCompletion,
      _errorCompletion,
    );
  }

  /// Called when the Facebook login is a success
  Future<void> _successCompletion(String loggedID) async {
    final userAlreadyExists = await UserRepository().usersExists(loggedID);
    if (userAlreadyExists) {
      await LocationController.instance.handleLocationIfNeeded();
      await UserLocalRepository.instance.rememberLoggedUser(loggedID);
      await UserStore.instance.initStore();
      Navigator.of(_context).pushReplacementNamed(Routes.map.value);
    } else
      Navigator.of(_context).pushReplacementNamed(Routes.startPathStep1.value);
  }

  void _cancelCompletion() {
    print('Login cancelled by the user.');
  }

  void _errorCompletion(String error) {
    print('Something went wrong with the login process.\n'
        'Here\'s the error Facebook gave us: $error');
  }
}
