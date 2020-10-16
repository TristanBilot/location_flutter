import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'helpers/location_controller.dart';
import 'pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocationController.instance.handleLocationIfNeeded();
  await UserStore
      .startingInstance; // should be remove after, just here to instance
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
