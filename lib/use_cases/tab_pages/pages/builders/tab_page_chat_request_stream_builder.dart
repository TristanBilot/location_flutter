import 'package:flutter/material.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/pages/builders/tab_page_stream_builder.dart';
import 'package:location_project/use_cases/tab_pages/pages/data/tab_page_stream_builder_data.dart';
import 'package:location_project/use_cases/tab_pages/pages/tab_page_type.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../stores/extensions.dart';

class TabPageChatRequestStreamBuilder implements TabPageStreamBuilder {
  final TabPageStreamBuilderData data;

  TabPageChatRequestStreamBuilder(this.data);

  Widget build(
    context,
    TabPageType type,
    AsyncSnapshot<dynamic> snapshot,
    bool shouldRefreshCache,
    TextEditingController _messageEditingController,
    RefreshController _refreshController,
    Function _onRefresh,
  ) {
    final sortedChats = _sortSnapshotsByMostRecent(snapshot.data.documents);
    final filteredChats =
        _filterStreamByName(sortedChats, _messageEditingController.text);
    final chats = data.filter(filteredChats);
    return SmartRefresher(
      enablePullDown: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: WaterDropMaterialHeader(), //WaterDropHeader
      child: chats.length != 0
          ? ListView.builder(
              itemCount: chats.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                bool isFirstIndex = index == 0;
                bool isLimitBetweenRequestedAndRequests = index ==
                    chats.indexWhere((chat) =>
                        (chat.data()[ChatField.RequesterID.value] as String) ==
                        UserStore().user.id);
                return ChatTile(
                  tabPageType: type,
                  chat: FirestoreChatEntry.fromFirestoreObject(
                      chats[index].data()),
                  shouldRefreshCache: shouldRefreshCache,
                  isFirstIndex: isFirstIndex,
                  isLimitBetweenRequestedAndRequests:
                      isLimitBetweenRequestedAndRequests,
                );
              })
          : data.placeholder,
    );
  }

  /// Sort the snapshots in ascending last message order.
  List<dynamic> _sortSnapshotsByMostRecent(List<dynamic> snapshots) {
    final mostRecent = ChatField.LastActivityTime.value;
    return snapshots
      ..sort((a, b) => (b.data()[mostRecent] as int)
          .compareTo((a.data()[mostRecent] as int)));
  }

  /// Return the same list of snapshots with only the chats with
  /// participants which the name match the string `pattern`.
  /// This function is used for the search feature.
  /// Return the same list of snapshots unchanged if `pattern` is empty.
  List<dynamic> _filterStreamByName(List<dynamic> snapshots, String pattern) {
    if (pattern.length == 0) return snapshots;
    return snapshots.where((snapshot) {
      final chat = FirestoreChatEntry.fromFirestoreObject(snapshot.data());
      final otherParticipantName = (chat.userNames
            ..removeWhere((userName) => userName == UserStore().user.firstName))
          .first;
      return otherParticipantName.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }
}
