import 'package:flutter/material.dart';
import 'package:location_project/theme_notifier.dart';
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
    return ChangeNotifierProvider<ThemeNotifier>(
        create: (context) => ThemeNotifier(),
        builder: (context, child) {
          return MaterialApp(
            initialRoute: Routes.map.value,
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
        });
  }
}