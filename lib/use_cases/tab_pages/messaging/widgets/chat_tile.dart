import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_rich_text.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_slidable.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';

class ChatTile extends StatefulWidget {
  final FirestoreChatEntry chat;
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

  /// Returns the user and the last msg printed in the tile.
  Future<List<dynamic>> _fetchUserAndLastMsg() async {
    final loggedUserID = UserStore().user.id;
    final remainingID = (widget.chat.userIDs..remove(loggedUserID)).first;
    bool useDatabase = !widget.shouldRefreshCache;
    final user = UserRepository().fetchUser(remainingID,
        useDatabase: useDatabase, withViews: false, withBlocks: false);
    final lastMsg = MessagingReposiory().getLastMessage(widget.chat.chatID);
    return Future.wait([user, lastMsg]);
  }

  /// Transforms the fetched user and last msg from firestore objects
  /// to real objects. If no message is already sent, msgEntry is null
  /// and need to be checked when printed.
  List<dynamic> _deserializeUserAndLastMsg(AsyncSnapshot<dynamic> snapshot) {
    final user = snapshot.data[0] as User;
    final noMessagesSent = snapshot.data[1].documents.length == 0;
    final msgEntry = noMessagesSent
        ? null
        : FirestoreMessageEntry.fromFirestoreObject(
            snapshot.data[1].documents[0].data());
    return [user, msgEntry];
  }

  /// Returns wether the last message is marked as unread or not.
  /// When the last msg is sent by the logged user, it should
  /// not be marked as unread.
  bool _shouldMarkMsgAsUnread(bool isChatEngaged, FirestoreMessageEntry msg) {
    if (!isChatEngaged) return false; // change later to support new match
    final loggedUserID = UserStore().user.id;
    if (loggedUserID == msg.sendBy) return false;
    return widget.chat.lastActivitySeen == false;
  }

  /// When the tile is tapped, update the last activity in Firestore
  /// using the repo, and then navigate to the message page.
  /// The last seen message should be update only if the last message
  /// emitter is the other person.
  void _onTileTapped(BuildContext context, User user, bool isChatEngaged,
      FirestoreMessageEntry lastMsg) {
    final loggedUserID = UserStore().user.id;
    if (isChatEngaged && lastMsg.sendBy != loggedUserID)
      MessagingReposiory()
          .updateChatLastActivity(widget.chat.chatID, lastActivitySeen: true);
    Navigator.push(
      context,
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
      FirestoreMessageEntry lastMsg, bool isChatEngaged, bool isMsgUnread) {
    final style =
        TextStyle(fontWeight: isMsgUnread ? unreadWeight : readWeight);
    if (!isChatEngaged) return Text('New discussion!', style: style);

    bool sentByMe = UserStore().user.id == lastMsg.sendBy;
    return Row(children: [
      sentByMe
          ? Icon(
              Icons.reply,
              color: Color.fromRGBO(170, 170, 170, 1),
              size: 18,
            )
          : Text(''),
      Text(' ${lastMsg.message}', style: style),
    ]);
  }

  void _onSharePress() {}

  _onUnmatchPress(ChatTile widget, String userName, context) {
    Color cancelButtonColor() {
      bool isDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      return isDark
          ? Color.fromRGBO(60, 60, 60, 1)
          : Color.fromRGBO(140, 140, 140, 1);
    }

    void onCancelPress() => Navigator.of(context).pop();

    void onUnmatchPress() {
      MessagingReposiory().deleteMessages(widget.chat.chatID);
      MessagingReposiory().deleteChat(widget.chat.chatID);
      Database()
          .deleteUser(widget.chat.requesterID)
          .then((value) => Navigator.of(context).pop());
    }

    showDialog(
      context: context,
      builder: (context) => BasicAlert(
        'Are you sure to unmatch $userName?',
        titleFontSize: 18,
        titleAlignment: TextAlign.center,
        contentPadding: EdgeInsets.only(bottom: 10),
        actions: [
          BasicAlertButton('CANCEL', onCancelPress, color: cancelButtonColor()),
          BasicAlertButton('UNMATCH', onUnmatchPress, color: Colors.red[500]),
        ],
      ),
    );
  }

  TabPageSlidable _getSlidableWithChild(User user, {@required Widget child}) {
    switch (widget.tabPageType) {
      case TabPageType.Discussions:
        return TabPageSlidable(
          child: child,
          action1: () => _onUnmatchPress(widget, user.firstName, context),
          action2: _onSharePress,
        );

      case TabPageType.Requests:
        return TabPageSlidable(
          isOnlyOneAction: true,
          child: child,
          action1: () => _onUnmatchPress(widget, user.firstName, context),
          action2: _onSharePress,
        );
      default:
        return null;
    }
  }

  Widget _getSectionTitleIfNeeded(context) {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserAndLastMsg(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final _deserialized = _deserializeUserAndLastMsg(snapshot);
          final user = _deserialized[0] as User;
          final msg = _deserialized[1] == null
              ? null
              : _deserialized[1] as FirestoreMessageEntry;
          // always verify `isChatEngaged` before using msg to
          // check if it is null = no message sent
          bool isChatEngaged = msg != null;
          bool isMsgUnread = _shouldMarkMsgAsUnread(isChatEngaged, msg);
          // if (!Database().keyExists(user.id)) Database().putUser(user);
          return GestureDetector(
            onTap: () => _onTileTapped(context, user, isChatEngaged, msg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _getSectionTitleIfNeeded(context),
                Card(
                  child: Column(
                    children: [
                      _getSlidableWithChild(
                        user,
                        child: ListTile(
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
                                        // border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          subtitle:
                              _getLastMsgText(msg, isChatEngaged, isMsgUnread),
                          trailing: Icon(Icons.chevron_right),
                          leading: CachedCircleUserImageWithActiveStatus(
                            pictureURL: user.pictureURL,
                            isActive: user.settings.connected,
                            onTapped: () => UserCard(context, user).show(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
