import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'interactors/auth_repository.dart';
import 'helpers/location_controller.dart';
import 'pages/login_page.dart';
import 'pages/map_page.dart';
import 'stores/routes.dart';
import 'stores/cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationController.init();
  await FacebookAuthController.init().logOut(); // ONLY FOR TESTS
  CacheManager.init();
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
