import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_refresher.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_search_bar.dart';
import 'package:provider/provider.dart';
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
  RefreshController _refreshController;
  TextEditingController _messageEditingController;
  ChatFilter _filter;

  // Only true when the refresh controller is used when
  // swipe is handle in order to refresh all the chats cache.
  bool _shouldRefreshCache;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _filter = ChatsFilter();
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

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  Widget get placeholder => BasicPlaceholder('No discussions yet.');
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
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatFetchedState) {
                  List<Chat> chats = _filter.filter(
                      state.chats, _messageEditingController.text);
                  MessagingDatabase().put(nbChats: chats.length);

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
                              return Builder(
                                builder: (context) => ChatTile(
                                  tabPageType: type,
                                  chat: chats[index],
                                  shouldRefreshCache: _shouldRefreshCache,
                                  isFirstIndex: isFirstIndex,
                                  isLimitBetweenRequestedAndRequests:
                                      isLimitBetweenRequestedAndRequests,
                                ),
                              );
                            })
                        : placeholder,
                  );
                }
                // TODO: handle other states
                return Center(child: CupertinoActivityIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
