import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/adapters/time_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_chats_requests_page.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cancelable_dialog.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_rich_text.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_search_bar.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_slidable.dart';
import 'package:location_project/widgets/home_page_status_without_count.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';
import 'package:provider/provider.dart';

class ChatTile extends StatefulWidget {
  final Chat chat;
  final bool shouldRefreshCache;
  final TabPageType tabPageType;

  /// Should display a section title for incoming requests on the first tile
  final bool isFirstIndex;

  /// Should display a section title for requests sent when the first
  /// requester tile is reached.
  final bool isLimitBetweenRequestedAndRequests;
  final bool shouldDisplaySearchBar;
  final TextEditingController messageEditingController;
  final SetStateDelegate setStateDelegate;

  const ChatTile({
    @required this.chat,
    @required this.shouldRefreshCache,
    @required this.tabPageType,
    this.isFirstIndex = false,
    this.isLimitBetweenRequestedAndRequests = false,
    this.shouldDisplaySearchBar,
    this.messageEditingController,
    this.setStateDelegate,
  });

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  static const FontWeight unreadWeight = FontWeight.w700;
  static const FontWeight readWeight = FontWeight.w300;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> _fetch() async {
    final loggedUserID = UserStore().user.id;
    final remainingID = (widget.chat.userIDs..remove(loggedUserID)).first;
    bool useDatabase = !widget.shouldRefreshCache;

    Future<Stream<List<Message>>> futureLastMSg() async =>
        MessagingReposiory().getLastMessage(widget.chat.chatID);

    Future<Stream<UserMandatoryInfo>> futureUser() async =>
        UserRepository().fetchUserInfoStream(remainingID);

    final lastMsgStream = futureLastMSg();
    final userInfoStream = futureUser();
    final userPictures = UserIconInfoFetcher().fetch(remainingID);
    return Future.wait([lastMsgStream, userInfoStream, userPictures]);
  }

  bool _shouldMarkMsgAsUnread(bool lastMessageExists, Message msg) {
    final chat = widget.chat;
    final userID = UserStore().user.id;

    if (!chat.isChatEngaged &&
        chat.requestedID == userID &&
        chat.myActivitySeen == false) return true;
    return chat.myActivitySeen == false;
  }

  _onTileTap(BuildContext thisContext, User user, bool isChatEngaged,
      Message lastMsg) {
    Navigator.push(
      thisContext,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: widget.chat,
          user: user,
        ),
      ),
    );
  }

  _onblockTap(User user) {
    CancelableDialog(
      context,
      'Are you sure to block ${user.firstName}?',
      BasicAlertButton(
        'BLOCK',
        () {
          HapticFeedback.mediumImpact();
          UserStore().addBlockedUser(user.id).then((_) async {
            context.read<ChatCubit>().deleteChat(widget.chat);
            Navigator.of(context).pop();
            // Envoyer un state pour rafraichir la map.
            // A terme, il ne faudrait pas rafraichir entierement la map car trop long.
            // Donc utiliser un cubit pour ça.
          });
        },
        color: Colors.red[500],
      ),
    ).show();
  }

  _onUnmatchTap(String userName) {
    CancelableDialog(
      context,
      'Are you sure to unmatch $userName?',
      BasicAlertButton(
        'UNMATCH',
        () {
          HapticFeedback.mediumImpact();
          context.read<ChatCubit>().deleteChat(widget.chat);
          Navigator.of(context).pop();
        },
        color: Colors.red[500],
      ),
    ).show();
  }

  Widget _getLastMsgText(
      Message lastMsg, bool lastMsgExists, bool isMsgUnread) {
    final style = TextSF.TextSFStyle.copyWith(
      fontWeight: isMsgUnread ? unreadWeight : readWeight,
      color: isMsgUnread ? Theme.of(context).textTheme.headline6.color : null,
    );
    final timeStyle = TextSF.TextSFStyle.copyWith(fontWeight: readWeight);
    if (!lastMsgExists && !widget.chat.isChatEngaged) return Text('');
    if (!lastMsgExists) return Text('New chat!', style: style);

    bool sentByMe = UserStore().user.id == lastMsg.sentBy;
    final time = TimeAdapter().adapt(lastMsg.time);
    return Row(children: [
      sentByMe
          ? Icon(Icons.reply, color: Color.fromRGBO(170, 170, 170, 1), size: 18)
          : Text(''),
      Flexible(
          child: Row(
        children: [
          Flexible(
              child: Text(' ${lastMsg.message}',
                  style: style, overflow: TextOverflow.ellipsis)),
          Text(' · $time',
              style: timeStyle.copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ],
      )),
    ]);
  }

  TabPageSlidable _getSlidableWithChild(User user, {@required Widget child}) {
    switch (widget.tabPageType) {
      case TabPageType.Discussions:
        return TabPageSlidable(
          child: child,
          action1: () => _onUnmatchTap(user.firstName),
          action2: () => _onblockTap(user),
        );
      case TabPageType.Requests:
        return TabPageSlidable(
          isOnlyOneAction: true,
          child: child,
          action1: () => _onUnmatchTap(user.firstName),
          action2: () => _onblockTap(user),
          text1: 'Remove',
        );
      default:
        return null;
    }
  }

  Widget get _searchBar => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: TabPageSearchBar(
          messageEditingController: widget.messageEditingController,
          setStateDelegate: widget.setStateDelegate,
        ),
      );

  Widget _getSectionTitleIfNeeded() {
    if (widget.tabPageType != TabPageType.Requests ||
        (!widget.isFirstIndex && !widget.isLimitBetweenRequestedAndRequests))
      return SizedBox();
    String text = '';
    if (widget.isLimitBetweenRequestedAndRequests)
      text = 'Requests';
    else if (widget.isFirstIndex) text = 'Invitations';
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color backgroundColor = isDark
        ? Theme.of(context).primaryColor
        : Color.fromRGBO(240, 240, 240, 1);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          if (widget.isFirstIndex && widget.shouldDisplaySearchBar) _searchBar,
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: TextSF(
              text,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Message _getSafeMessage(AsyncSnapshot<dynamic> snapshot) {
    if (!snapshot.hasData || snapshot.data == null || snapshot.data.isEmpty)
      return null;
    return snapshot.data.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetch(),
      builder: (futureContext, snapshot) {
        if (snapshot.hasData) {
          final lastMsgStream = snapshot.data[0] as Stream<List<Message>>;
          final userInfoStream = snapshot.data[1] as Stream<UserMandatoryInfo>;
          final userPictures = snapshot.data[2] as UserIconInfo;

          return StreamBuilder(
            stream: userInfoStream,
            builder: (context, userSnapshot) {
              if (userSnapshot.hasData) {
                final userInfo = userSnapshot.data as UserMandatoryInfo;
                final user = User.public()
                  ..build(infos: userInfo)
                  ..build(pictures: userPictures);

                return StreamBuilder(
                    stream: lastMsgStream,
                    builder: (context, lastMsgSnapshot) {
                      final msg = _getSafeMessage(lastMsgSnapshot);
                      // always check `lastMessageExists` before using msg
                      bool lastMsgExists = msg != null;
                      bool isMsgUnread =
                          _shouldMarkMsgAsUnread(lastMsgExists, msg);

                      return GestureDetector(
                        onTap: () =>
                            _onTileTap(futureContext, user, lastMsgExists, msg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _getSectionTitleIfNeeded(),
                            Column(
                              children: [
                                _getSlidableWithChild(
                                  user,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Row(
                                          children: [
                                            Expanded(
                                              // display name and distance
                                              child: TabPageRichText(
                                                user.firstName,
                                                user.distance,
                                                isMsgUnread: isMsgUnread,
                                              ),
                                            ),
                                            isMsgUnread
                                                ? HomePageStatusWithoutCount()
                                                : SizedBox(),
                                          ],
                                        ),
                                        subtitle: _getLastMsgText(
                                            msg, lastMsgExists, isMsgUnread),
                                        trailing: Icon(Icons.chevron_right),
                                        leading:
                                            CachedCircleUserImageWithActiveStatus(
                                          pictureURL: user.mainPictureURL,
                                          isActive: user.settings.connected,
                                          borderColor: Colors.transparent,
                                          onTapped: () =>
                                              UserCard(context, user).show(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              }
              return Container();
            },
          );
        }
        return Container();
      },
    );
  }
}
