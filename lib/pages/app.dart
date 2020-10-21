import 'package:flutter/material.dart';
import 'package:location_project/helpers/messaging_example.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/user_store.dart';
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

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the user put the app in background
  /// or come back to background.
  /// Change the connected status to true or false.
  /// Also put at true at the beginning of the app (main).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!UserLocalRepository().isUserLoggedIn()) return;
    if (state == AppLifecycleState.resumed)
      UserStore().setConnectedStatus(true);
    if (state == AppLifecycleState.paused)
      UserStore().setConnectedStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: Routes.test.value,
      initialRoute:
          UserStore().isuserLoggedIn() ? Routes.map.value : Routes.login.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (context) => LoginPage(),
        Routes.map.value: (context) => MapPage(),
        Routes.account.value: (context) => AccountPage(),
        Routes.languages.value: (context) => AccountLanguagePage(),
        Routes.startPathStep1.value: (context) => StartPathStep1(),
        Routes.startPathStep2.value: (context) => StartPathStep2(),
        Routes.startPathStep3.value: (context) => StartPathStep3(),
        Routes.startPathStep4.value: (context) => StartPathStep4(),
        Routes.test.value: (context) => PushMessagingExample(),
      },
      theme: AppTheme.defaultTheme,
      darkTheme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.copyWith(
                bodyText2: ThemeData.dark()
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.white),
              )),
      debugShowCheckedModeBanner: false,
    );
  }
}
