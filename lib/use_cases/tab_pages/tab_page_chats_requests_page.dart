import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/stores/user_store.dart';
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
  TextEditingController _messageEditingController;
  ChatFilter _filter;

  // Only true when the refresh controller is used when
  // swipe is handle in order to refresh all the chats cache.
  bool _shouldRefreshCache;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _filter = widget.type == TabPageType.Discussions
        ? ChatsFilter()
        : RequestFilter();
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

  Future<void> _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    // need to be improved later, set to false after stream building, not build().
    await Future.delayed(
        Duration(milliseconds: 800), () => _shouldRefreshCache = false);
  }

  Widget get placeholder => widget.type == TabPageType.Discussions
      ? BasicPlaceholder('No discussions yet.')
      : BasicPlaceholder('No requests yet.');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TabPageSearchBar(
          //     messageEditingController: _messageEditingController,
          //     setStateDelegate: this,
          //   ),
          // ),
          SizedBox(height: 3),
          Flexible(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatFetchedState) {
                  List<Chat> chats = _filter.filter(
                      state.chats, _messageEditingController.text);
                  if (widget.type == TabPageType.Discussions)
                    MessagingDatabase().put(nbChats: chats.length);
                  else
                    MessagingDatabase().put(nbRequests: chats.length);

                  return chats.length != 0
                      ? CustomScrollView(
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
                                bool isLimitBetweenRequestedAndRequests =
                                    index ==
                                        chats.indexWhere((chat) =>
                                            chat.requesterID ==
                                            UserStore().user.id);
                                return Builder(
                                  builder: (context) => ChatTile(
                                    tabPageType: widget.type,
                                    chat: chats[index],
                                    shouldRefreshCache: _shouldRefreshCache,
                                    isFirstIndex: isFirstIndex,
                                    isLimitBetweenRequestedAndRequests:
                                        isLimitBetweenRequestedAndRequests,
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
    );
  }
}
