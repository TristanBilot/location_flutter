import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/pages/messaging_tabs_page.dart';
import 'package:location_project/use_cases/account/account_page.dart';
import 'package:location_project/use_cases/map/map_page.dart';
import 'package:location_project/use_cases/swipe_card/swipe_page.dart';

class NavigationBarItem {
  final Widget page;
  final String title;
  final Icon icon;

  NavigationBarItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<NavigationBarItem> get items => [
        NavigationBarItem(
          page: AccountPage(),
          icon: Icon(Icons.home),
          title: '',
        ),
        NavigationBarItem(
          page: SwipePage(),
          icon: Icon(Icons.shopping_basket),
          title: '',
        ),
        NavigationBarItem(
          page: MapPage(),
          icon: Icon(Icons.search),
          title: '',
        ),
        NavigationBarItem(
          page: MessagingTabsPage(),
          icon: Icon(Icons.search),
          title: '',
        ),
      ];
}
