import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location_project/theme_changer.dart';
import 'interactors/auth_repository.dart';
import 'helpers/location_controller.dart';
import 'stores/cache_manager.dart';
import 'package:provider/provider.dart';
import 'theme_changer.dart';
import 'pages/app.dart';

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
    return App();
  }
}
