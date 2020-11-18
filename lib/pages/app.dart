import 'package:flutter/material.dart';
import 'package:location_project/helpers/messaging_example.dart';
import 'package:location_project/repositories/user_local_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/account/account_blocked_users_page.dart';
import 'package:location_project/use_cases/account/account_language_page.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/start_path_step3/start_path_step3.dart';
import 'package:location_project/use_cases/start_path/start_path_step4/start_path_step4.dart';
import 'package:location_project/use_cases/tab_pages/widgets/test.dart';
import 'package:location_project/generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../pages/login_page.dart';
import 'home_page.dart';
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
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      // initialRoute: Routes.startPathStep1.value,
      // initialRoute: 'test',

      initialRoute:
          UserStore().isuserLoggedIn() ? Routes.map.value : Routes.login.value,
      routes: <String, WidgetBuilder>{
        Routes.login.value: (context) => LoginPage(),
        Routes.map.value: (context) => HomePage(),
        Routes.account.value: (context) => AccountPage(),
        Routes.languages.value: (context) => AccountLanguagePage(),
        Routes.blockedUsers.value: (context) => AccountBlockedUsersPage(),
        Routes.startPathStep1.value: (context) => StartPathStep1(),
        Routes.startPathStep2.value: (context) => StartPathStep2(),
        Routes.startPathStep3.value: (context) => StartPathStep3(),
        Routes.startPathStep4.value: (context) => StartPathStep4(),
        Routes.test.value: (context) => PushMessagingExample(),
        'test': (context) => CupertinoRefreshControlDemo(),
      },
      theme: LightTheme.defaultTheme,
      darkTheme: DarkTheme.defaultTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
