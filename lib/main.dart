import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'map.dart';
import 'facebookAuthController.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final mapPageTitle = 'Real time Location';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/map',
      routes: <String, WidgetBuilder>{
        '/map': (BuildContext context) => MyHomePage(title: mapPageTitle),
      },
      title: mapPageTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: mapPageTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _facebookAuthController = FacebookAuthController();

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(height: 400, width: 374, child: MapPage()),
            FlatButton(
              onPressed: () => _facebookAuthController.logOut,
              child: Icon(Icons.remove_circle),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _facebookAuthController.logIn(context),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
