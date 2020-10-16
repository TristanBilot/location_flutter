import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/repositories/login_controller.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';

import '../repositories/auth_repository.dart';
import '../stores/routes.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController _loginController;

  @override
  void initState() {
    super.initState();

    _loginController = LoginController(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Log in')),
        body: Center(
            child: Container(
                child: Column(
          children: [
            Spacer(),
            FacebookSignInButton(
              onPressed: () => _loginController.logIn(),
            ),
            SizedBox(height: 20),
            FlatButton(
                child: Container(
                  color: Colors.green,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Text(
                    'Route to map',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Routes.map.value);
                }),
            Spacer(),
          ],
        ))));
  }
}
