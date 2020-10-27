import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/messaging/cahed_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/message_page.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/widgets/user_card.dart';

class ChatTile extends StatelessWidget {
  final FirestoreChatEntry chat;
  final shouldRefreshCache;

  const ChatTile({
    @required this.chat,
    @required this.shouldRefreshCache,
  });

  static const FontWeight unreadWeight = FontWeight.w700;
  static const FontWeight readWeight = FontWeight.w300;

  /// Returns the user and the last msg printed in the tile.
  Future<List<dynamic>> _fetchUserAndLastMsg() async {
    final loggedUserID = UserStore().user.id;
    final remainingID = (chat.userIDs..remove(loggedUserID)).first;
    Future<User> user;
    // The cached user should be stored in the streambuilder because
    // here we are working with futures.
    if (shouldRefreshCache || !Database().keyExists(remainingID))
      user = UserRepository().getUserFromID(remainingID);
    else
      user = Database().getFutureUser(remainingID);

    final lastMsg = MessagingReposiory().getLastMessage(chat.chatID);
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
    return chat.lastActivitySeen == false;
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
          .updateChatLastActivity(chat.chatID, lastActivitySeen: true);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: chat,
          user: user,
        ),
      ),
    );
  }

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
          print('=> in chats: ${user.email}');
          // Database().manageCache(user);
          if (!Database().keyExists(user.id)) Database().putUser(user);
          return GestureDetector(
            onTap: () => _onTileTapped(context, user, isChatEngaged, msg),
            child: Card(
              child: Column(
                children: [
                  Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: [
                      IconSlideAction(
                        caption: 'Share profile',
                        color: Colors.indigo,
                        icon: Icons.share,
                        onTap: () => {},
                      ),
                      IconSlideAction(
                        caption: 'Unmatch',
                        color: Colors.red[500],
                        icon: Icons.close,
                        onTap: () => {},
                      ),
                    ],
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color),
                                children: [
                                  TextSpan(
                                    text: '${user.firstName}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isMsgUnread
                                            ? unreadWeight
                                            : FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: '  -  ${user.distance}m',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: readWeight,
                                    ),
                                  ),
                                ],
                              ),
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
          );
        }
        return Container();
      },
    );
  }
}
