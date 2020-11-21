import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location_project/controllers/init_controller.dart';
import 'package:location_project/repositories/login_controller.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';

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
              SvgPicture.asset(
                'assets/logo2.svg',
                height: 300,
              ),
              Spacer(),
              FacebookSignInButton(
                  borderRadius: BasicButton.CornerRadius,
                  onPressed: () => _loginController.logIn()),
              SizedBox(height: 20),
              // BasicButton('Route to map', onPressed: () {
              //   Navigator.pushReplacementNamed(context, Routes.map.value);
              // }),
              BasicButton('Log as Tristan',
                  onPressed: () => _loginController
                      .logInFromEmail('bilot.tristan.carrieres@hotmail.fr')),
              BasicButton('Log as Damien',
                  onPressed: () => _loginController
                      .logInFromEmail('damien.duprat.carrieres@hotmail.fr')),
              BasicButton('Log as Alexandre',
                  onPressed: () => _loginController
                      .logInFromEmail('alexandre.roume.carrieres@hotmail.fr')),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
