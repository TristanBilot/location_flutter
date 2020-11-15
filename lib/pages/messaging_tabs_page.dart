import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/views/cubit/view_cubit.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_discussions_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_requests_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_views_page.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_element_count_status.dart';

class MessagingTabsPage extends StatefulWidget {
  MessagingTabsPage();

  @override
  _MessagingTabsPageState createState() => _MessagingTabsPageState();
}

class _MessagingTabsPageState extends State<MessagingTabsPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(icon: Icon(Icons.account_circle)),
    Tab(icon: Icon(Icons.location_on)),
    Tab(icon: Icon(Icons.textsms))
  ];

  @override
  void initState() {
    super.initState();
  }

  Color _getTabColor() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Color.fromRGBO(33, 33, 33, 1) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatCubit(MessagingReposiory())),
        BlocProvider(create: (context) => ViewCubit(UserRepository())),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: BlocBuilder<CountersCubit, CountersState>(
              builder: (context, state) {
                return AppBar(
                  backgroundColor: _getTabColor(),
                  bottom: TabBar(
                    labelPadding: EdgeInsets.only(bottom: 10),
                    labelColor: Theme.of(context).textTheme.headline6.color,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: [
                      TabPageElementCountStatus(
                          'Messages', state.counter.nbUnreadChats),
                      TabPageElementCountStatus(
                          'Requests', state.counter.nbRequests),
                      TabPageElementCountStatus('Views', state.counter.nbViews),
                    ],
                  ),
                );
              },
              // title: Text('Tabs Demo'),
            ),
          ),
          body: TabBarView(
            children: [
              TabPageDiscussionsPage(),
              TabPageRequestsPage(),
              TabPageViewsPage(),
            ],
          ),
        ),
      ),
    );
  }
}
