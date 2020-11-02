import 'package:flutter/material.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_factory.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_template.dart';
import 'package:location_project/widgets/textSF.dart';

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
  // TabController _tabController;
  // final _initialIndex = 1;

  @override
  void initState() {
    // _tabController = TabController(
    //     vsync: this, length: tabs.length, initialIndex: _initialIndex);
    super.initState();
  }

  Color _getTabColor() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Color.fromRGBO(33, 33, 33, 1) : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: AppBar(
            backgroundColor: _getTabColor(),
            bottom: TabBar(
              labelPadding: EdgeInsets.only(bottom: 10),
              labelColor: Theme.of(context).textTheme.headline6.color,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                TextSF('DISCUSSIONS'),
                TextSF('REQUESTS'),
                TextSF('VIEWS'),
              ],
            ),
            // title: Text('Tabs Demo'),
          ),
        ),
        body: TabBarView(
          children: [
            TabPageFactory().makeDiscussionsPage(),
            TabPageFactory().makeRequestsPage(),
            TabPageFactory().makeViewsPage(),
          ],
        ),
      ),
    );
  }
}
