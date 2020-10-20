import 'package:flutter/material.dart';
import 'package:location_project/caches/location_cache.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/pages/location_disabled_page.dart';
import 'package:location_project/use_cases/matchs/matchs.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/messaging/chats_page.dart';
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
    return LocationCache().isLocationAvailable &&
        await LocationController().isLocationEnabled();
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

  /// Called when the app come from background.
  /// Update the UI and the map if the user change the
  /// location permissions in settings and come back to
  /// the app.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LocationController().handleLocationIfNeeded().then((value) {
        setState(() {});
        print('come back to foreground');
      });
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
            AccountPage(),
            FutureBuilder(
              future: _displayMapIfLocationEnabled(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  bool shouldDisplayMap = snapshot.data;
                  return shouldDisplayMap ? Map() : LocationDisabledPage();
                } else {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  );
                }
              },
            ),
            // Matchs(),
            ChatsPage(),
          ],
        ),
      ),
      PositionedAppIcon(_tabController, _initialIndex)
    ]);
  }
}
