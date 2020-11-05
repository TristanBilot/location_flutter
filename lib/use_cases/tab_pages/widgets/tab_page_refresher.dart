import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabPageRefresher extends StatefulWidget {
  final RefreshController refreshController;
  final Function onRefresh;
  final Widget child;

  TabPageRefresher(
    this.onRefresh,
    this.refreshController,
    this.child,
  );

  @override
  _TabPageRefresherState createState() => _TabPageRefresherState();
}

class _TabPageRefresherState extends State<TabPageRefresher> {
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      controller: widget.refreshController,
      onRefresh: widget.onRefresh,
      header: WaterDropMaterialHeader(), //WaterDropHeader
      child: widget.child,
    );
  }
}
