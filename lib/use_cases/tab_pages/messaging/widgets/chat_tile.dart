import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/adapters/time_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_deleting_state.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_rich_text.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_slidable.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';
import 'package:provider/provider.dart';

class ChatTile extends StatefulWidget {
  // final BuildContext context;
  final Chat chat;
  final bool shouldRefreshCache;
  final TabPageType tabPageType;

  /// Should display a section title for incoming requests on the first tile
  final bool isFirstIndex;

  /// Should display a section title for requests sent when the first
  /// requester tile is reached.
  final bool isLimitBetweenRequestedAndRequests;

  const ChatTile({
    @required this.chat,
    @required this.shouldRefreshCache,
    @required this.tabPageType,
    this.isFirstIndex = false,
    this.isLimitBetweenRequestedAndRequests = false,
  });

  @override
  _ChatTileState createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  static const FontWeight unreadWeight = FontWeight.w700;
  static const FontWeight readWeight = FontWeight.w300;

  /// Returns wether the last message is marked as unread or not.
  /// When the last msg is sent by the logged user, it should
  /// not be marked as unread.
  bool _shouldMarkMsgAsUnread(bool isChatEngaged, Message msg) {
    if (!isChatEngaged) return false; // change later to support new match
    final loggedUserID = UserStore().user.id;
    if (loggedUserID == msg.sendBy) return false;
    return widget.chat.lastActivitySeen == false;
  }

  void _onTileTapped(BuildContext thisContext, User user, bool isChatEngaged,
      Message lastMsg) {
    final loggedUserID = UserStore().user.id;
    if (isChatEngaged && lastMsg.sendBy != loggedUserID)
      MessagingReposiory()
          .updateChatLastActivity(widget.chat.chatID, lastActivitySeen: true);
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

  /// Format the text with sent icon with the last message sent.
  Widget _getLastMsgText(
      Message lastMsg, bool isChatEngaged, bool isMsgUnread) {
    final style = TextSF.TextSFStyle.copyWith(
        fontWeight: isMsgUnread ? unreadWeight : readWeight);
    if (!isChatEngaged && !widget.chat.isChatEngaged) return Text('');
    if (!isChatEngaged) return Text('New chat!', style: style);

    bool sentByMe = UserStore().user.id == lastMsg.sendBy;
    final time = TimeAdapter().adapt(lastMsg.time);
    return Row(children: [
      sentByMe
          ? Icon(
              Icons.reply,
              color: Color.fromRGBO(170, 170, 170, 1),
              size: 18,
            )
          : Text(''),
      Flexible(
          child: Container(
        child: Text(' ${lastMsg.message} · $time',
            style: style, overflow: TextOverflow.ellipsis),
      )),
    ]);
  }

  void _onSharePress() {}

  _onUnmatchPress(ChatTile widget, String userName) {
    Color cancelButtonColor() {
      bool isDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      return isDark
          ? Color.fromRGBO(60, 60, 60, 1)
          : Color.fromRGBO(140, 140, 140, 1);
    }

    void onCancelPress() => Navigator.of(context).pop();

    void onUnmatchPress() => context.read<ChatCubit>().deleteChat(widget.chat);

    showDialog(
      context: context,
      builder: (context) => BasicAlert(
        'Are you sure to unmatch $userName?',
        titleFontSize: 18,
        titleAlignment: TextAlign.center,
        contentPadding: EdgeInsets.only(bottom: 10),
        actions: [
          BasicAlertButton('CANCEL', onCancelPress, color: cancelButtonColor()),
          BasicAlertButton('UNMATCH', () => onUnmatchPress(),
              color: Colors.red[500]),
        ],
      ),
    );
  }

  _triggerUnmatchPress() {
    Navigator.of(context).pop();
  }

  TabPageSlidable _getSlidableWithChild(User user, {@required Widget child}) {
    switch (widget.tabPageType) {
      case TabPageType.Discussions:
        return TabPageSlidable(
          child: child,
          action1: () => _onUnmatchPress(widget, user.firstName),
          action2: _onSharePress,
        );
      case TabPageType.Requests:
        return TabPageSlidable(
          isOnlyOneAction: true,
          child: child,
          action1: () => _onUnmatchPress(widget, user.firstName),
          action2: _onSharePress,
          text1: 'Remove',
        );
      default:
        return null;
    }
  }

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
      child: Container(
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
    );
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
    final userPictures = UserPicturesInfoFetcher().fetch(remainingID);
    return Future.wait([lastMsgStream, userInfoStream, userPictures]);
  }

  Message _getSafeMessage(AsyncSnapshot<dynamic> snapshot) {
    if (!snapshot.hasData || snapshot.data == null || snapshot.data.isEmpty)
      return null;
    return snapshot.data.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listener: (blocContext, state) {
        if (state is ChatDeletedState) _triggerUnmatchPress();
      },
      child: FutureBuilder(
        future: _fetch(),
        builder: (futureContext, snapshot) {
          if (snapshot.hasData) {
            final lastMsgStream = snapshot.data[0] as Stream<List<Message>>;
            final userInfoStream =
                snapshot.data[1] as Stream<UserMandatoryInfo>;
            final userPictures = snapshot.data[2] as UserPicturesInfo;

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
                        // always check `isChatEngaged` before using msg
                        bool isChatEngaged = msg != null;
                        bool isMsgUnread =
                            _shouldMarkMsgAsUnread(isChatEngaged, msg);

                        return GestureDetector(
                          onTap: () => _onTileTapped(
                              futureContext, user, isChatEngaged, msg),
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
                                                  ? Container(
                                                      height: 10,
                                                      width: 10,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: PrimaryColor,
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                          subtitle: _getLastMsgText(
                                              msg, isChatEngaged, isMsgUnread),
                                          trailing: Icon(Icons.chevron_right),
                                          leading:
                                              CachedCircleUserImageWithActiveStatus(
                                            pictureURL: user.pictureURL,
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
      ),
    );
  }
}
