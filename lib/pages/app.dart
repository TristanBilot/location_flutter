import 'package:flutter/material.dart';
import 'package:location_project/themes/app_theme.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/start_path_step3/start_path_step3.dart';
import 'package:location_project/use_cases/start_path/start_path_step4/start_path_step4.dart';
import '../pages/login_page.dart';
import '../pages/map_page.dart';
import '../stores/routes.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Routes.startPathStep1.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (context) => LoginPage(),
        Routes.map.value: (context) => MapPage(),
        Routes.account.value: (context) => AccountPage(),
        Routes.languages.value: (context) => AccountLanguagePage(),
        Routes.startPathStep1.value: (context) => StartPathStep1(),
        Routes.startPathStep2.value: (context) => StartPathStep2(),
        Routes.startPathStep3.value: (context) => StartPathStep3(),
        Routes.startPathStep4.value: (context) => StartPathStep4(),
      },
      theme: AppTheme.defaultTheme,
      darkTheme: ThemeData.dark(),
    );
  }
}
