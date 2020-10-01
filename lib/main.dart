import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interactors/auth_repository.dart';
import 'helpers/location_controller.dart';
import 'pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationController.init();
  FacebookAuthController.init(); //.logOut(); // ONLY FOR TESTS
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
