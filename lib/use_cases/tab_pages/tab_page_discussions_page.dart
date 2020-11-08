import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_refresher.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_search_bar.dart';
import '../../stores/extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class SetStateDelegate {
  void setStateFromOutside();
}

class TabPageDiscussionsPage extends StatefulWidget {
  @override
  _TabPageDiscussionsPageState createState() => _TabPageDiscussionsPageState();
}

class _TabPageDiscussionsPageState extends State<TabPageDiscussionsPage>
    implements SetStateDelegate {
  Stream<QuerySnapshot> _stream;
  RefreshController _refreshController;
  TextEditingController _messageEditingController;

  // Only true when the refresh controller is used when
  // swipe is handle in order to refresh all the chats cache.
  bool _shouldRefreshCache;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _shouldRefreshCache = false;
    _fetchChatsStream();

    super.initState();
  }

  @override
  void setStateFromOutside() => setState(() => {});

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future<void> _fetchChatsStream() async {
    Stopwatch stopwatch = Stopwatch()..start();
    final userID = UserStore().user.id;
    _stream = await MessagingReposiory().getChats(userID);
    int discussionsFetchingTime = stopwatch.elapsed.inMilliseconds;
    setStateIfMounted(() =>
        Logger().v("discussions fetched in ${discussionsFetchingTime}ms."));
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

  Function(List<dynamic>) get _filter => (snapshots) => snapshots
      .where(
          (chat) => chat.data()[ChatField.IsChatEngaged.value] as bool == true)
      .toList();

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  Widget get placeholder => TabPagePlaceholer('No discussions yet.');
  TabPageType get type => TabPageType.Discussions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabPageSearchBar(
              messageEditingController: _messageEditingController,
              setStateDelegate: this,
            ),
          ),
          Flexible(
            child: StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sortedChats =
                      _sortSnapshotsByMostRecent(snapshot.data.documents);
                  final filteredChats = _filterStreamByName(
                      sortedChats, _messageEditingController.text);
                  final chats = _filter(filteredChats);
                  return TabPageRefresher(
                    _onRefresh,
                    _refreshController,
                    chats.length != 0
                        ? ListView.builder(
                            itemCount: chats.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              bool isFirstIndex = index == 0;
                              bool isLimitBetweenRequestedAndRequests = index ==
                                  chats.indexWhere((chat) =>
                                      (chat.data()[ChatField.RequesterID.value]
                                          as String) ==
                                      UserStore().user.id);
                              return ChatTile(
                                tabPageType: type,
                                chat: FirestoreChatEntry.fromFirestoreObject(
                                    chats[index].data()),
                                shouldRefreshCache: _shouldRefreshCache,
                                isFirstIndex: isFirstIndex,
                                isLimitBetweenRequestedAndRequests:
                                    isLimitBetweenRequestedAndRequests,
                              );
                            })
                        : placeholder,
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
