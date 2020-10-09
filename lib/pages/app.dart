import 'package:flutter/material.dart';
import 'package:location_project/themes/app_theme.dart';
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
      initialRoute: Routes.login.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (context) => LoginPage(),
        Routes.map.value: (context) => MapPage(),
      },
      theme: AppTheme.defaultTheme,
      darkTheme: ThemeData.dark(),
    );
  }
}
