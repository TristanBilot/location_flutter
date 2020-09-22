import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'map.dart';
import 'loginPage.dart';
import 'facebookAuthController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FacebookAuthController.init().logOut(); // ONLY FOR TESTS
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final mapPageTitle = 'Real time Location';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => LoginPage(),
        '/map': (BuildContext context) => MyHomePage(title: mapPageTitle),
      },
      title: mapPageTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [MapPage()],
        ));
  }
}
