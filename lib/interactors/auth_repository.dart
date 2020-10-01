import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helpers/location_controller.dart';
import '../stores/repository.dart';
import '../models/user.dart' as my;
import 'user_repository.dart';

class FacebookAuthController {
  static FacebookAuthController instance;

  final _userRepo = UserRepository();
  final _repo = Repository();
  final _facebookLogin = FacebookLogin();
  final _graphDataURL =
      'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(100)&access_token=';

  /* 
  ^ FUNCTION 
  * This sould be the first function used to init this class
  * Only use the `instance` field like FacebookAuthController.instance.
  */
  static FacebookAuthController init() {
    return instance = instance == null ? FacebookAuthController() : instance;
  }

  /* 
  ^ FUNCTION 
  * Try to log in to Facebook and FirebaseAuth, get the user infos
  * and create a new user object.
  * After that, the user is inserted into the firestore or updates if 
  * it already exists: `insertUser(user)`
  */
  Future<void> logIn(BuildContext context) async {
    /* maybe to change for auto connection to facebook */
    _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    final result = await _facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        await _logToFirebaseAndUpdateData(context, result.accessToken.token);
        break;

      case FacebookLoginStatus.cancelledByUser:
        print('Login cancelled by the user.');
        break;

      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        break;
    }
  }

  /*
  ^ FUNCTION
  * Log out from Facebook API
  */
  Future<void> logOut() async {
    await _facebookLogin.logOut();
  }

  /*
  ^ PRIVATE FUNCTION
  * This function is called when the Facebook log in is a success.
  * It try to connect to FirebaseAuth and fetch user's json data 
  * in order to insert or update the database
*/
  Future _logToFirebaseAndUpdateData(BuildContext context, String token) async {
    await FirebaseAuth.instance
        .signInWithCredential(FacebookAuthProvider.credential(token));
    /* get Facebook profile */
    final graphResponse = await http.get(_graphDataURL + token);
    final data = json.decode(graphResponse.body);
    final id = data['email'];
    final icon = await _repo.fetchUserIcon(id);
    // final downloadURL = await _repo.getPictureDownloadURL(id);

    my.User fbUser = my.User(
        data['email'],
        data['first_name'],
        data['last_name'],
        LocationController.location,
        icon,
        data['picture']['data']['url']);

    final hasPicture = !data['picture']['data']['is_silhouette'];
    if (hasPicture) {
      await _userRepo.insertOrUpdateUser(fbUser);
      Navigator.of(context).pushReplacementNamed('/map');
    } else {/* redirect to picker */}
    print('[+] ' + fbUser.email + ' connected !');
    await logOut(); // LOG OUT
  }
}
