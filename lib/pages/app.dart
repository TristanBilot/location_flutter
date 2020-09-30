import 'package:flutter/material.dart';
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
      darkTheme: ThemeData.dark(),
      title: 'je sais pas',
      // theme: Provider.of<ThemeNotifier>(context).getTheme() ==
      //         Brightness.dark
      //     ? ThemeData.dark()
      //     : ThemeData.light(),
      // home: LoginPage(),
    );
  }
}
