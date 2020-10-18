import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location_project/stores/user_store.dart';
import 'helpers/location_controller.dart';
import 'pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setup();
  runApp(MyApp());
}

Future setup() async {
  await LocationController.instance.handleLocationIfNeeded();
  await UserStore.startingInstance;
  await UserStore.instance.initStore();
  UserStore.instance.setConnectedStatus(true);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
