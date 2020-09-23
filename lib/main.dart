import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interactors/authRepository.dart';
import 'helpers/locationController.dart';
import 'pages/loginPage.dart';
import 'pages/mapPage.dart';
import 'stores/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationController.init();
  await FacebookAuthController.init().logOut(); // ONLY FOR TESTS
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.map.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (BuildContext context) => LoginPage(),
        Routes.map.value: (BuildContext context) => MapPage(),
      },
      title: 'je sais pas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: LoginPage(),
    );
  }
}
