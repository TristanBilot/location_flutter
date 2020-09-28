import 'package:flutter/material.dart';
import 'package:location_project/theme_changer.dart';
import '../pages/login_page.dart';
import '../pages/map_page.dart';
import '../stores/routes.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    // final theme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      initialRoute: Routes.map.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (BuildContext context) => LoginPage(),
        Routes.map.value: (BuildContext context) => MapPage(),
      },
      title: 'je sais pas',
      // theme: theme.getTheme()
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: LoginPage(),
    );
  }
}
