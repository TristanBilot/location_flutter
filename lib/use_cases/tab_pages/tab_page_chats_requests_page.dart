import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/request_filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:provider/provider.dart';

abstract class SetStateDelegate {
  void setStateFromOutside();
}

class TabPageChatsRequestsPage extends StatefulWidget {
  final TabPageType type;

  const TabPageChatsRequestsPage(this.type);

  @override
  _TabPageRequestsPageState createState() => _TabPageRequestsPageState();
}

class _TabPageRequestsPageState extends State<TabPageChatsRequestsPage>
    implements SetStateDelegate {
  static const NumberOfChatsToDisplaySearchBar = 10;
  TextEditingController _messageEditingController;
  ScrollController _scrollController;
  ChatFilter _filter;

  // Only true when the refresh controller is used when
  // swipe is handle in order to refresh all the chats cache.
  bool _shouldRefreshCache;

  @override
  void initState() {
    _init();
    _messageEditingController = TextEditingController();
    _scrollController = ScrollController();
    _shouldRefreshCache = false;
    _fetch();
    // _hideSearchBarIfNeeded();
    super.initState();
  }

  @override
  void setStateFromOutside() => setState(() => {});

  void _init() {
    if (widget.type == TabPageType.Discussions) {
      _filter = ChatsFilter();
      MemoryStore().setDisplayToastValues(false, true, true, false, '');
    } else if (widget.type == TabPageType.Requests) {
      _filter = RequestFilter();
      MemoryStore().setDisplayToastValues(true, false, true, true, '');
    }
  }

  void _fetch() {
    context.read<ChatCubit>().fetchChats();
  }

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  /// To improve.
  // _hideSearchBarIfNeeded() async {
  //   bool enoughChats = MessagingDatabase().get(nbChats: true) >=
  //       NumberOfChatsToDisplaySearchBar;
  //   bool enoughRequests = MessagingDatabase().get(nbRequests: true) >=
  //       NumberOfChatsToDisplaySearchBar;
  //   if (enoughChats && widget.type == TabPageType.Discussions ||
  //       enoughRequests && widget.type == TabPageType.Requests)
  //     Future.delayed(Duration(milliseconds: 10))
  //         .then((value) => _scrollController.jumpTo(55));
  // }

  Future<void> _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    HapticFeedback.mediumImpact();
    // need to be improved later, set to false after stream building, not build().
    await Future.delayed(Duration(milliseconds: 800), () {
      _shouldRefreshCache = false;
      HapticFeedback.lightImpact();
    });
  }

  Widget get placeholder => widget.type == TabPageType.Discussions
      ? BasicPlaceholder('No discussions yet.')
      : BasicPlaceholder('No requests yet.');

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  'Messages',
                  style: TextStyle(
                      color: ThemeUtils.getBlackIfLightAndWhiteIfDark(context)),
                ),
              )
            ];
          },
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
            },
            child: Column(
              children: [
                SizedBox(height: 3),
                Flexible(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      if (state is ChatFetchedState) {
                        List<Chat> chats = _filter.filter(
                            state.chats, _messageEditingController.text);
                        // if (widget.type == TabPageType.Discussions)
                        //   MessagingDatabase().put(nbChats: chats.length);
                        // else
                        //   MessagingDatabase().put(nbRequests: chats.length);

                        return chats.length != 0
                            ? CustomScrollView(
                                controller: _scrollController,
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                slivers: [
                                  CupertinoSliverRefreshControl(
                                      onRefresh: _onRefresh),
                                  SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      bool isFirstIndex = index == 0;
                                      bool shouldDisplaySearchBar =
                                          chats.length >=
                                              NumberOfChatsToDisplaySearchBar;
                                      bool isLimitBetweenRequestedAndRequests =
                                          index ==
                                              chats.indexWhere((chat) =>
                                                  chat.requesterID ==
                                                  UserStore().user.id);

                                      return Builder(
                                        builder: (context) => ChatTile(
                                          tabPageType: widget.type,
                                          chat: chats[index],
                                          shouldRefreshCache:
                                              _shouldRefreshCache,
                                          isFirstIndex: isFirstIndex,
                                          isLimitBetweenRequestedAndRequests:
                                              isLimitBetweenRequestedAndRequests,
                                          shouldDisplaySearchBar:
                                              shouldDisplaySearchBar,
                                          messageEditingController:
                                              _messageEditingController,
                                          setStateDelegate: this,
                                        ),
                                      );
                                    },
                                    childCount: chats.length,
                                  )),
                                ],
                              )
                            : placeholder;
                      }
                      // TODO: handle other states
                      return Center(child: CupertinoActivityIndicator());
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
