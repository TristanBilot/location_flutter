import 'package:flutter/material.dart';
import 'package:location_project/widgets/positioned_app_icon.dart';
import '../widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: Scaffold(
          appBar: AppBar(
              bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings)),
              Tab(
                child: Container(
                  color: Colors.transparent,
                  // child: Text('hey'),
                ),
              ),
              Tab(icon: Icon(Icons.account_circle)),
            ],
          )),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Icon(Icons.directions_bike),
              Map(),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
      PositionedAppIcon()
    ]);
  }
}
