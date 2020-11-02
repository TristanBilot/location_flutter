import 'package:flutter/material.dart';
import 'package:location_project/use_cases/messaging/pages/data/tab_page_stream_builder_data.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_type.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class TabPageStreamBuilder {
  TabPageStreamBuilderData get data;

  Widget build(
    context,
    TabPageType type,
    AsyncSnapshot<dynamic> snapshot,
    bool shouldRefreshCache,
    TextEditingController _messageEditingController,
    RefreshController _refreshController,
    Function _onRefresh,
  );
}
