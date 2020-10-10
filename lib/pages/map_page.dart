import 'package:flutter/material.dart';
import 'package:location_project/use_cases/matchs/matchs.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/widgets/positioned_app_icon.dart';
import '../widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.account_circle)),
    Tab(child: Text('')),
    Tab(icon: Icon(Icons.textsms))
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
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            StartPathStep1(),
            Map(),
            Matchs(),
          ],
        ),
      ),
      PositionedAppIcon(_tabController, _initialIndex)
    ]);
  }
}
