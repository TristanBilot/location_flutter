import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'facebookUserJSON.dart';

class FacebookAuthController {
  final _facebookLogin = FacebookLogin();
  final _graphDataURL =
      'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=';

  Future<void> logIn(BuildContext context, Function completion) async {
    final _ = await _facebookLogin.logInWithReadPermissions(
        ['email', 'public_profile']).then((result) async {
      final token = result.accessToken.token;

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final _ = await FirebaseAuth.instance
              .signInWithCredential(FacebookAuthProvider.credential(token));

          final graphResponse = await http.get(_graphDataURL + token);
          final data = json.decode(graphResponse.body);
          FacebookUserJSON fbUser = FacebookUserJSON(
              data['first_name'],
              data['last_name'],
              data['email'],
              data['picture']['data']['url'],
              !data['picture']['data']['is_silhouette']);
          print(fbUser.toString());
          completion(fbUser);

          if (fbUser.hasPicture) {
            Navigator.of(context).pushReplacementNamed('/map');
          } else {
            /* redirect to picker */
          }

          print('CONNECTED');
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
