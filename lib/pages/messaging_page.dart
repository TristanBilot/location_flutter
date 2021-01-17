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
import 'package:location_project/use_cases/tab_pages/messaging/widgets/match_image.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:provider/provider.dart';

class MessagingPage extends StatefulWidget {
  const MessagingPage();

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  static const NumberOfChatsToDisplaySearchBar = 10;
  TextEditingController _messageEditingController;
  ScrollController _scrollController;
  ChatFilter _filter;

  bool _shouldRefreshCache;

  @override
  void initState() {
    _init();
    _messageEditingController = TextEditingController();
    _scrollController = ScrollController();
    _shouldRefreshCache = false;
    _fetch();
    super.initState();
  }

  void _init() {
    _filter = ChatsFilter();
    MemoryStore().setDisplayToastValues(false, true, true, false, '');
    // else if (widget.type == TabPageType.Requests) {
    //   _filter = RequestFilter();
    //   MemoryStore().setDisplayToastValues(true, false, true, true, '');
    // }
  }

  void _fetch() {
    context.read<ChatCubit>().fetchChats();
  }

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

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

  Widget get _placeholder => BasicPlaceholder('No discussions yet.');

  Widget _swipableMatchesRow(List<Chat> requests) {
    final id = UserStore().user.id;
    return Container(
      margin: EdgeInsets.only(top: 20),
      height: MatchImage.ImageSize + 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: requests.map((chat) {
          final remainingID = ([...chat.userIDs]..remove(id)).first;
          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: MatchImage(remainingID, chat),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                heroTag: 'tag2',
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
                        List<Chat> requests = NewMatchFilter().filter(
                            state.chats, _messageEditingController.text);
                        // MessagingDatabase().put(nbChats: chats.length);

                        return chats.length + requests.length != 0
                            ? Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 10),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: TextSF(
                                        'NEW MATCHES',
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black38,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _swipableMatchesRow(requests),
                                  Divider(),
                                  Flexible(
                                    child: CustomScrollView(
                                      controller: _scrollController,
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      slivers: [
                                        CupertinoSliverRefreshControl(
                                            onRefresh: _onRefresh),
                                        SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                          (context, index) {
                                            bool isFirstIndex = index == 0;
                                            bool shouldDisplaySearchBar = chats
                                                    .length >=
                                                NumberOfChatsToDisplaySearchBar;
                                            bool
                                                isLimitBetweenRequestedAndRequests =
                                                index ==
                                                    chats.indexWhere((chat) =>
                                                        chat.requesterID ==
                                                        UserStore().user.id);

                                            return Builder(
                                              builder: (context) => ChatTile(
                                                tabPageType:
                                                    TabPageType.Discussions,
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
                                                setStateDelegate: null,
                                              ),
                                            );
                                          },
                                          childCount: chats.length,
                                        )),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : _placeholder;
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
