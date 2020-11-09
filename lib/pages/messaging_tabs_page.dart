import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/messaging_tab_pages_counted_elements.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_discussions_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_requests_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_views_page.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_element_count_status.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:provider/provider.dart';

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
    Provider.of<MessagingTabPagesCountedElements>(context, listen: false)
        .initCounts();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Consumer<MessagingTabPagesCountedElements>(
            builder: (context, counts, child) {
              return AppBar(
                backgroundColor: _getTabColor(),
                bottom: TabBar(
                  labelPadding: EdgeInsets.only(bottom: 10),
                  labelColor: Theme.of(context).textTheme.headline6.color,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: [
                    TabPageElementCountStatus('MESSAGES', counts.nbDiscussions),
                    TabPageElementCountStatus('REQUESTS', counts.nbRequests),
                    TabPageElementCountStatus('VIEWS', counts.nbViews),
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
    );
  }
}
