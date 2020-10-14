import 'package:flutter/material.dart';
import 'package:location_project/helpers/location_controller.dart';
import 'package:location_project/pages/location_disabled_page.dart';
import 'package:location_project/use_cases/matchs/matchs.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/widgets/positioned_app_icon.dart';
import '../widgets/map.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.account_circle)),
    Tab(child: Text('')),
    Tab(icon: Icon(Icons.textsms))
  ];
  final _initialIndex = 1;
  TabController _tabController;

  Future<bool> _displayMapIfLocationEnabled() async {
    return await LocationController.instance.isLocationEnabled();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(
        vsync: this, length: tabs.length, initialIndex: _initialIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      print('heyyy');
    }
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
            FutureBuilder(
              future: _displayMapIfLocationEnabled(),
              builder: (context, snapshot) {
                if (snapshot.hasData)
                  return snapshot.data == false
                      ? LocationDisabledPage()
                      : Map();
                else {
                  return Text('waiting...');
                }
              },
            ),
            Matchs(),
          ],
        ),
      ),
      PositionedAppIcon(_tabController, _initialIndex)
    ]);
  }
}
