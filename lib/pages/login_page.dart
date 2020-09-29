import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import '../theme_notifier.dart';
import 'package:provider/provider.dart';
import '../interactors/auth_repository.dart';

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
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Log in')),
        body: Stack(
          alignment: Alignment.topLeft,
          children: [
            FacebookSignInButton(
              onPressed: () => _facebookAuthController.logIn(context),
            ),
            Text(
                themeNotifier.getTheme() == Brightness.dark ? 'dark' : 'light'),
          ],
        ));
  }
}
