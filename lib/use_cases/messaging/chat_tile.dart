import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/message_page.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';

class ChatTile extends StatelessWidget {
  final FirestoreChatEntry chat;

  const ChatTile({
    @required this.chat,
  });

  Future<User> _fetchUserFromID() async {
    final loggedUserID = UserStore().user.id;
    final remainingID = chat.userIDs..remove(loggedUserID);
    return await UserRepository().getUserFromID(remainingID.first);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserFromID(),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessagePage(
                            chatID: chat.chatID,
                          )),
                ),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          snapshot.data.firstName,
                        ),
                        subtitle: Text('At ${snapshot.data.distance}m'),
                        trailing: Icon(Icons.chevron_right),
                        leading: CachedCircleUserImage(
                          snapshot.data.pictureURL,
                          size: 55,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container();
      },
    );
  }
}
