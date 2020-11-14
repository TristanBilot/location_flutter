import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_discussions_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_refresher.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_search_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabPageRequestsPage extends StatefulWidget {
  @override
  _TabPageRequestsPageState createState() => _TabPageRequestsPageState();
}

class _TabPageRequestsPageState extends State<TabPageRequestsPage>
    implements SetStateDelegate {
  Stream<QuerySnapshot> _stream;
  RefreshController _refreshController;
  TextEditingController _messageEditingController;

  bool _shouldRefreshCache;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _shouldRefreshCache = false;
    _fetch();

    super.initState();
  }

  @override
  void setStateFromOutside() => setState(() => {});

  void _fetch() {
    context.read<ChatCubit>().fetchChats();
  }

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  List<Chat> _sortChatsByMostRecent(List<Chat> chats) {
    return chats
      ..sort((a, b) => b.lastActivityTime.compareTo(a.lastActivityTime));
  }

  List<Chat> _filterChatsByName(List<Chat> chats, String pattern) {
    if (pattern.length == 0) return chats;
    return chats.where((chat) {
      final otherParticipantName = (chat.userNames
            ..removeWhere((userName) => userName == UserStore().user.firstName))
          .first;
      return otherParticipantName.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }

  List<Chat> _filter(List<Chat> chats, String pattern) {
    return _sortChatsByMostRecent(_filterChatsByName(chats, pattern))
        .where((chat) => !chat.isChatEngaged)
        .toList()
          ..sort((a, b) => b.requestedID == UserStore().user.id ? 1 : -1);
  }

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  Widget get placeholder => TabPagePlaceholer('No requests yet.');
  TabPageType get type => TabPageType.Requests;

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
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatFetchedState) {
                  List<Chat> chats =
                      _filter(state.chats, _messageEditingController.text);
                  MessagingDatabase().putNbRequests(chats.length);

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
                                      chat.requesterID == UserStore().user.id);
                              return ChatTile(
                                tabPageType: type,
                                chat: chats[index],
                                shouldRefreshCache: _shouldRefreshCache,
                                isFirstIndex: isFirstIndex,
                                isLimitBetweenRequestedAndRequests:
                                    isLimitBetweenRequestedAndRequests,
                              );
                            })
                        : placeholder,
                  );
                }
                return Center(child: CupertinoActivityIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
