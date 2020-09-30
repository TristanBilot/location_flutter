import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import '../theme_notifier.dart';
import 'package:provider/provider.dart';
import '../interactors/auth_repository.dart';
import '../stores/routes.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _facebookAuthController = FacebookAuthController.instance;

  @override
  void initState() {
    super.initState();
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
              onPressed: () => _facebookAuthController.logIn(context),
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
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.map.value)),
            Spacer(),
          ],
        ))));
  }
}
