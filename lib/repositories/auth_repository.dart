import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/store.dart';
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

  /* 
  ^ FUNCTION 
  * Try to log in to Facebook and FirebaseAuth, get the user infos
  * and create a new user object.
  * After that, the user is inserted into the firestore or updates if 
  * it already exists: `insertUser(user)`
  */
  Future<void> logIn(
    Function(String loggedID) success,
    Function cancelled,
    Function(String error) error,
  ) async {
    /* maybe to change for auto connection to facebook */
    _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await _facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        await _loginWithFacebook(result.accessToken.token, success);
        break;

      case FacebookLoginStatus.cancelledByUser:
        cancelled();
        break;

      case FacebookLoginStatus.error:
        error(result.errorMessage);
        break;
    }
  }

  /*
  ^ FUNCTION
  * Log out from Facebook API and clear shared preferences
  */
  Future<void> logOut() async {
    await _forgetLoggedUser();
    await _facebookLogin.logOut();
  }

  /*
  ^ PRIVATE FUNCTION
  * This function is called when the Facebook log in is a success.
  * It trie to connect to FirebaseAuth and fetch user's json data 
  * in order to insert or update the database
*/
  Future _loginWithFacebook(
      String token, Function(String loggedID) successCompletion) async {
    await FirebaseAuth.instance
        .signInWithCredential(FacebookAuthProvider.credential(token));
    /* get Facebook profile */
    final graphResponse = await http.get(_graphDataURL + token);
    final data = json.decode(graphResponse.body);
    final id = data['email'];
    final icon = await _repo.fetchUserIcon(id);

    my.User fbUser = my.User(
      data['email'],
      data['first_name'],
      data['last_name'],
      LocationCache().location,
      icon,
      data['picture']['data']['url'],
      0,
      UserSettings.DefaultUserSettings,
    );

    final hasPicture = !data['picture']['data']['is_silhouette'];
    if (hasPicture) {
      if (!await _userRepo.usersExists(id))
        await _userRepo.insertUserForFirstConnection(fbUser);
    } else {/* redirect to picker */}
    /* init of the UserCache, no use should be done before that */

    successCompletion(id);
    // await logOut();
    print('[+] ' + fbUser.email + ' connected !');
  }

  /// See UserLocalRepository.rememberLoggedUser
  Future<void> _rememberLoggedUser(String id) async {
    return UserLocalRepository().rememberLoggedUser(id);
  }

  /// See UserLocalRepository.forgetLoggedUser
  Future<void> _forgetLoggedUser() async {
    return UserLocalRepository().forgetLoggedUser();
  }
}
