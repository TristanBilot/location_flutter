import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/controllers/app_badge_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/pages/map_page.dart';
import 'package:location_project/pages/messaging_tabs_page.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/swipe_card/swipe_page.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif_listener.dart';
import 'package:location_project/widgets/home_page_status_without_count.dart';
import 'package:location_project/widgets/home_page_tab_bar_icon.dart';
import 'package:location_project/widgets/home_page_tab_bar_image_icon.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    listenToNotifications(context);

    return BlocProvider(
      create: (context) => CountersCubit(context, MessagingDatabase())..init(),
      child: HomePageContainer(),
    );
  }
}

class HomePageContainer extends StatefulWidget {
  HomePageContainer({Key key}) : super(key: key);

  @override
  _HomePageContainerState createState() => _HomePageContainerState();
}

class _HomePageContainerState extends State<HomePageContainer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const NbTabs = 4;
  final _initialIndex = 1;
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _tabController =
        TabController(vsync: this, length: NbTabs, initialIndex: _initialIndex);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() => setState(() {});

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
        AppBadgeController().updateAppBadge();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: AppBar(
          elevation: 1,
          backgroundColor: ThemeUtils.getTabColor(context),
          bottom: TabBar(
            indicatorColor:
                Colors.transparent, // Theme.of(context).primaryColor,
            tabs: [
              // Tab 1.
              Tab(
                  icon: HomePageTabBarIcon(
                      Icons.account_circle, _tabController.index == 0)),
              Tab(
                icon:
                    HomePageTabBarIcon(Icons.swipe, _tabController.index == 1),
              ),
              // Tab 2.
              Tab(icon: HomePageTabBarImageIcon(_tabController.index == 2)),
              // Tab 3.
              Tab(
                  icon: Container(
                      width: 40, // to fix position of status
                      height: 30,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          HomePageTabBarIcon(
                              Icons.textsms, _tabController.index == 3),
                          BlocBuilder<CountersCubit, CountersState>(
                              builder: (context, state) {
                            if (state.isANotificationUnread())
                              return Align(
                                  alignment: Alignment.topRight,
                                  child: HomePageStatusWithoutCount());
                            return SizedBox();
                          })
                        ],
                      )))
            ],
            controller: _tabController,
          ),
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          AccountPage(),
          SwipePage(),
          MapPage(),
          MessagingTabsPage(),
        ],
      ),
      // PositionedAppIcon(_tabController, _initialIndex)
    );
  }
}
