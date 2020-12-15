import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:location_project/controllers/init_controller.dart';
import 'pages/app.dart';

void main() async {
  Paint.enableDithering = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await InitController().initFromMain();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return App();
  }
}
