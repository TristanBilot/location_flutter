import 'package:flutter/material.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountNotificationsPage extends StatefulWidget {
  @override
  _AccountNotificationsPageState createState() =>
      _AccountNotificationsPageState();
}

class _AccountNotificationsPageState extends State<AccountNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextSF(
        'Notifications',
        fontSize: 16,
      )),
      body: Material(
        child: ListView(children: [
          AccountListTile(
            title: 'Messages',
            trailing: Switch.adaptive(
              value: UserStore().user.getNotifSett(NotifType.Messages),
              onChanged: (_) {
                UserStore().toggleNotificationSettings(NotifType.Messages);
                setState(() => {});
              },
            ),
          ),
          AccountListTile(
            title: 'Conversations',
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.Chats),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.Chats);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Requests',
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.Requests),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.Requests);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Profile views',
            withDivider: false,
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.Views),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.Views);
                  setState(() => {});
                }),
          ),
        ]),
      ),
    );
  }
}
