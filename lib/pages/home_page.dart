import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/controllers/app_badge_controller.dart';
import 'package:location_project/controllers/location_controller.dart';
import 'package:location_project/pages/messaging_page.dart';
import 'package:location_project/use_cases/premium/premium_page.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/use_cases/account/edit%20profile/cubit/edit_profile_cubit.dart';
import 'package:location_project/use_cases/blocking/cubit/blocking_cubit.dart';
import 'package:location_project/use_cases/map/cubit/area_cubit.dart';
import 'package:location_project/use_cases/map/map_page.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/map/repositories/area_fetching_repository.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_page.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif_listener.dart';
import 'package:location_project/use_cases/tab_pages/messaging/views/cubit/view_cubit.dart';
import 'package:location_project/use_cases/tab_pages/navigation/cubit/navigation_cubit.dart';
import 'package:location_project/widgets/home_page_status_without_count.dart';
import 'package:location_project/widgets/home_page_tab_bar_icon.dart';
import 'package:location_project/widgets/home_page_tab_bar_image_icon.dart';
import 'package:preload_page_view/preload_page_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    listenToNotifications(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                CountersCubit(context, MessagingDatabase())..init()),
        BlocProvider(create: (context) => SwipeCubit()..fetchUsersFeed()),
        BlocProvider(create: (context) => AreaCubit(AreaFetchingRepository())),
        BlocProvider(create: (context) => BlockingCubit()),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(create: (context) => SwipeButtonsCubit()),
        BlocProvider(create: (context) => ChatCubit(MessagingReposiory())),
        BlocProvider(create: (context) => ViewCubit(UserRepository())),
        BlocProvider(create: (context) => EditProfileCubit(UserRepository())),
      ],
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
  static const int BaseTabIndex = 2;

  final _pages = [
    AccountPage(),
    SwipePage(),
    MapPage(),
    MessagingPage(),
    PremiumPage(),
  ];

  PreloadPageController _pageController;
  int _tabIndex = BaseTabIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: BaseTabIndex);

    WidgetsBinding.instance.addObserver(this);
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
      LocationController().handleLocationIfNeeded().then((_) {
        setState(() {});
        print('come back to foreground');
        AppBadgeController().updateAppBadge();
      });
    }
  }

  _onPageChanged(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PreloadPageView(
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        preloadPagesCount: _pages.length,
      ),
      bottomNavigationBar: BlocListener<NavigationCubit, NavigationState>(
        listener: (context, state) {
          if (state is NavigateToIndexState)
            setState(() => _tabIndex = state.index);
        },
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          type: BottomNavigationBarType.shifting,
          items: [
            BottomNavigationBarItem(
                icon: HomePageTabBarIcon(Icons.account_circle, _tabIndex == 0),
                label: ''),
            BottomNavigationBarItem(
                icon: HomePageTabBarIcon(Icons.swipe, _tabIndex == 1),
                label: ''),
            BottomNavigationBarItem(
                icon: HomePageTabBarImageIcon(_tabIndex == 2), label: ''),
            BottomNavigationBarItem(
                icon: Container(
                    width: 40, // to fix position of status
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        HomePageTabBarIcon(Icons.textsms, _tabIndex == 3),
                        BlocBuilder<CountersCubit, CountersState>(
                            builder: (context, state) {
                          if (state is CounterStoreState &&
                              state.isANotificationUnread() &&
                              (state.counter.nbUnreadChats > 0 ||
                                  state.counter.nbNewMatches > 0))
                            return Align(
                                alignment: Alignment.topRight,
                                child: HomePageStatusWithoutCount());
                          return SizedBox();
                        })
                      ],
                    )),
                label: ''),
            BottomNavigationBarItem(
                icon: Container(
                    width: 40, // to fix position of status
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        HomePageTabBarIcon(Icons.favorite, _tabIndex == 4),
                        BlocBuilder<CountersCubit, CountersState>(
                            builder: (context, state) {
                          if (state is CounterStoreState &&
                              state.isANotificationUnread() &&
                              (state.counter.nbNewLikes > 0 ||
                                  state.counter.nbNewViews > 0))
                            return Align(
                                alignment: Alignment.topRight,
                                child: HomePageStatusWithoutCount());
                          return SizedBox();
                        })
                      ],
                    )),
                label: ''),
          ],
          onTap: (index) {
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }
}
