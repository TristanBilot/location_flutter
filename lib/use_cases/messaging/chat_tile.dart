import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/cahed_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/message_page.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';

class ChatTile extends StatelessWidget {
  final FirestoreChatEntry chat;

  const ChatTile({
    @required this.chat,
  });

  Future<List<dynamic>> _fetchUserAndLastMsg() async {
    final loggedUserID = UserStore().user.id;
    final remainingID = chat.userIDs..remove(loggedUserID);
    final user = UserRepository().getUserFromID(remainingID.first);
    final lastMsg = MessagingReposiory().getLastMessage(chat.chatID);
    return Future.wait([user, lastMsg]);
  }

  List<dynamic> _deserializeUserAndLastMsg(AsyncSnapshot<dynamic> snapshot) {
    final user = snapshot.data[0] as User;
    final noMessagesSent = snapshot.data[1].documents.length == 0;
    final msgEntry = noMessagesSent
        ? null
        : FirestoreMessageEntry.fromFirestoreObject(
            snapshot.data[1].documents[0].data());
    final msg = noMessagesSent ? 'New match!' : msgEntry.message;
    return [user, msg];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserAndLastMsg(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final _deserialized = _deserializeUserAndLastMsg(snapshot);
          final user = _deserialized[0] as User;
          final msg = _deserialized[1] as String;
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MessagePage(
                        chatID: chat.chatID,
                        user: user,
                      )),
            ),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    title: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '${user.firstName}'),
                          TextSpan(
                              text: '  -  ${user.distance}m',
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w300)),
                        ],
                      ),
                    ),
                    subtitle: Text(msg), //Text('$m'),
                    trailing: Icon(Icons.chevron_right),
                    leading: CachedCircleUserImageWithActiveStatus(
                      pictureURL: user.pictureURL,
                      isActive: user.settings.connected,
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
