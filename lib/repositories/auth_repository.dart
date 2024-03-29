import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:location_project/conf/store.dart';
import 'package:location_project/controllers/device_id_controller.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/storage/shared preferences/local_store.dart';
import 'package:location_project/storage/databases/user_database.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'dart:convert';

import 'image_repository.dart';
import '../models/user.dart' as my;
import 'user_repository.dart';

class AuthRepository {
  final _graphDataURL =
      'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(${Store.downloadedFbProfileImageSize})&access_token=';

  UserRepository _userRepo;
  ImageRepository _repo;
  FacebookLogin _facebookLogin;

  AuthRepository() {
    _userRepo = UserRepository();
    _repo = ImageRepository();
    _facebookLogin = FacebookLogin();
  }

  /// Try to log in to Facebook and FirebaseAuth, get the user infos
  /// and create a new user object.
  /// After that, the user is inserted into the firestore or updates if
  /// it already exists: `insertUser(user)`
  Future<void> logIn(
    Function(String loggedID) successUserExists,
    Function(my.User newUser) successUserDoesNotExists,
    Function cancelled,
    Function(String error) error,
  ) async {
    /* maybe to change for auto connection to facebook */
    _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await _facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        await _loginWithFacebook(
          result.accessToken.token,
          successUserExists,
          successUserDoesNotExists,
        );
        break;

      case FacebookLoginStatus.cancelledByUser:
        cancelled();
        break;

      case FacebookLoginStatus.error:
        error(result.errorMessage);
        break;
    }
  }

  /// Log out from Facebook API and clear shared preferences
  Future<void> logOut() async {
    UserStore().setConnectedStatus(false);
    await DeviceIDController().forgetDeviceID();
    await LocalStore().clear();
    await MessagingDatabase().clear();
    // await UserDatabase().clear();
    await _facebookLogin.logOut();
  }

  /// This function is called when the Facebook log in is a success.
  /// It tries to connect to FirebaseAuth and fetch user's json data
  /// in order to insert or update the database.
  Future _loginWithFacebook(
    String token,
    Function(String loggedID) successUserExists,
    Function(my.User newUser) successUserDoesNotExists,
  ) async {
    await FirebaseAuth.instance
        .signInWithCredential(FacebookAuthProvider.credential(token));
    /* get Facebook profile */
    final graphResponse = await http.get(_graphDataURL + token);
    final data = json.decode(graphResponse.body);
    final id = data['email'];

    if (await _userRepo.usersExists(id)) {
      successUserExists(id);
      print('[+] $id connected !');
      return;
    }
    _createNewUserFromFacebook(data, successUserDoesNotExists);
  }

  Future _createNewUserFromFacebook(
    dynamic data,
    Function(my.User newUser) successUserDoesNotExists,
  ) async {
    final id = data['email'];

    my.User fbUser = my.User(
      id,
      data['first_name'],
      data['last_name'],
      List<double>.from([
        0,
        0
      ]), // FIXME UPDATE LOCATION FOR THE LOGGED USER LocationCache().location
      null,
      (data['picture']['data']['url'] as List)?.cast<String>(),
      0,
      null,
      null,
      UserSettings.DefaultUserSettings,
      List<String>(),
      List<String>(),
      List<View>(),
      List<View>(),
      List<String>(),
      '',
    );

    final hasPicture = !data['picture']['data']['is_silhouette'];
    if (hasPicture) {
      successUserDoesNotExists(fbUser);
      // await _userRepo.insertUserForFirstConnection(fbUser);
    } else {/* redirect to picker */}
  }
}
