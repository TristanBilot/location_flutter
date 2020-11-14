import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/pages/map_page.dart';
import 'package:location_project/pages/messaging_tabs_page.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return HomePageContainer();
  }
}

class HomePageContainer extends StatefulWidget {
  HomePageContainer({Key key}) : super(key: key);

  @override
  _HomePageContainerState createState() => _HomePageContainerState();
}

class _HomePageContainerState extends State<HomePageContainer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.account_circle)),
    Tab(icon: Icon(Icons.location_on)),
    Tab(icon: Icon(Icons.textsms))
  ];
  final _initialIndex = 1;
  TabController _tabController;

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
    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              bottom: TabBar(
                tabs: tabs,
                controller: _tabController,
              ),
            ),
          ),
          body: BlocProvider(
            create: (context) => CountersCubit(MessagingDatabase()),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                AccountPage(),
                MapPage(),
                MessagingTabsPage(),
              ],
            ),
          ),
        ),
        // PositionedAppIcon(_tabController, _initialIndex)
      ],
    );
  }
}
