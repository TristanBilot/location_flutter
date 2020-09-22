import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FacebookAuthController {
  var _facebookLogin = FacebookLogin();

  Future<void> logIn(BuildContext context) async {
    _facebookLogin
        .logInWithReadPermissions(['email', 'public_profile']).then((result) {
      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          FirebaseAuth.instance
              .signInWithCredential(
                  FacebookAuthProvider.credential(result.accessToken.token))
              .then((signedInUser) async {
            print(signedInUser.additionalUserInfo.username);
            Navigator.of(context).pushReplacementNamed('/map');

            // var graphResponse = await http.get(
            //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult.accessToken.token}');
            // var profile = json.decode(graphResponse.body);
            // print(profile.toString());
          }).catchError((e) => print(e));
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
