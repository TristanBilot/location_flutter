import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/pages/data/tab_page_stream_builder_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../tab_page_type.dart';

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
