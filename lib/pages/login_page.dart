import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:location_project/theme_changer.dart';
import 'package:provider/provider.dart';
import '../interactors/auth_repository.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final _facebookAuthController = FacebookAuthController.instance;
  final _themeChanger = ThemeChanger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    print('hey');
    _themeChanger.setTheme(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeChanger>(
      builder: (context, themeChanger, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
                themeChanger.getTheme() == Brightness.dark ? 'dark' : 'light'),
          ),
          body: FacebookSignInButton(
            onPressed: () => _facebookAuthController.logIn(context),
          ),
        );
      },
    );
  }
}
