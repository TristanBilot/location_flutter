import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_rich_text.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_slidable.dart';
import 'package:location_project/widgets/user_card.dart';

/// Fetch a user from a user ID and display a tile.
class TabPageViewTile extends StatefulWidget {
  final String userID;
  final bool shouldRefreshCache;

  const TabPageViewTile(
    this.userID,
    this.shouldRefreshCache,
  );

  @override
  _TabPageViewTileState createState() => _TabPageViewTileState();
}

class _TabPageViewTileState extends State<TabPageViewTile> {
  Future<User> _fetchUser() async {
    final id = widget.userID;
    bool useCache = !widget.shouldRefreshCache && Database().keyExists(id);
    return await UserRepository().getUserCachedFromID(id, useCache: useCache);
  }

  // void _onTileTapped(BuildContext context, User user, bool isChatEngaged,
  //     FirestoreMessageEntry lastMsg) {
  //   final loggedUserID = UserStore().user.id;
  //   if (isChatEngaged && lastMsg.sendBy != loggedUserID)
  //     MessagingReposiory()
  //         .updateChatLastActivity(widget.chat.chatID, lastActivitySeen: true);
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => MessagePage(
  //         chat: widget.chat,
  //         user: user,
  //       ),
  //     ),
  //   );

  _onRemoveViewTap(String viewerID) {
    final id = UserStore().user.id;
    UserRepository()
        .deleteCollectionSnapshot(id, UserField.UserIDsWhoWiewedMe, viewerID);
    UserRepository()
        .deleteCollectionSnapshot(viewerID, UserField.ViewedUserIDs, id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data as User;
          print('=> in views: ${user.email}');

          return GestureDetector(
            onTap: () => {}, //_onTileTapped(context, user, isChatEngaged, msg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Column(
                    children: [
                      TabPageSlidable(
                        isOnlyOneAction: true,
                        action1: () => _onRemoveViewTap(user.id),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                // display name and distance
                                child: TabPageRichText(
                                  user.firstName,
                                  user.distance,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.chevron_right),
                          leading: CachedCircleUserImageWithActiveStatus(
                            pictureURL: user.pictureURL,
                            isActive: false, //user.settings.connected,
                            onTapped: () => UserCard(context, user).show(),
                            size: 45,
                            borderColor: Colors.transparent,
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
