import 'package:flutter/material.dart';
import 'package:location_project/widgets/positioned_app_icon.dart';
import '../widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.settings)),
    Tab(child: Text('')),
    Tab(icon: Icon(Icons.account_circle)),
  ];
  final _initialIndex = 1;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
        vsync: this, length: tabs.length, initialIndex: _initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: tabs,
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Icon(Icons.directions_bike),
            Map(),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
      PositionedAppIcon(_tabController, _initialIndex)
    ]);

    //     length: tabs.length,
    //     initialIndex: 1,
    //     child: Scaffold(
    //       appBar: AppBar(
    //           bottom: TabBar(
    //         tabs: tabs,
    //       )),
    //       body: TabBarView(
    //         physics: NeverScrollableScrollPhysics(),
    //         children: [
    //           Icon(Icons.directions_bike),
    //           Map(),
    //           Icon(Icons.directions_bike),
    //         ],
    //       ),
    //     ),
    //   ),
    //   PositionedAppIcon()
    // ]);
  }
}
