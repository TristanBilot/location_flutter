import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/facebookUserJSON.dart';
import 'areaFetcher.dart';

/*
 * static FacebookAuthController init()
 * Future<void> logIn(BuildContext context) async
 * Future<void> logOut() async
 */

class FacebookAuthController {
  static FacebookAuthController instance;

  final _areaFetcher = AreaFetcher();
  final _facebookLogin = FacebookLogin();
  final _graphDataURL =
      'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(100)&access_token=';

  static FacebookAuthController init() {
    return instance = instance == null ? FacebookAuthController() : instance;
  }

  Future<void> logIn(BuildContext context) async {
    _facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

    final _ = await _facebookLogin.logInWithReadPermissions(
        ['email', 'public_profile']).then((result) async {
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final token = result.accessToken.token;
          final _ = await FirebaseAuth.instance
              .signInWithCredential(FacebookAuthProvider.credential(token));

          /* get Facebook profile */
          final graphResponse = await http.get(_graphDataURL + token);
          final data = json.decode(graphResponse.body);
          FacebookUserJSON fbUser = FacebookUserJSON(
              data['first_name'],
              data['last_name'],
              data['email'],
              data['picture']['data']['url'],
              !data['picture']['data']['is_silhouette']);
          print(fbUser.toString());

          if (fbUser.hasPicture) {
            /* insert/update user's data and profile picture */
            await _areaFetcher.insertUser(fbUser);
            Navigator.of(context).pushReplacementNamed('/map');
          } else {
            /* redirect to picker */
          }

          print('CONNECTED');
          await logOut(); // LOG OUT
          break;

        case FacebookLoginStatus.cancelledByUser:
          print('Login cancelled by the user.');
          break;

        case FacebookLoginStatus.error:
          print('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.errorMessage}');
          break;
      }
    });
  }

  Future<void> logOut() async {
    await _facebookLogin.logOut();
  }
}
