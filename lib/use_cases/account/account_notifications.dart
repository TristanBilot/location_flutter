import 'package:flutter/material.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/widgets/scaffold_title.dart';

class AccountNotificationsPage extends StatefulWidget {
  @override
  _AccountNotificationsPageState createState() =>
      _AccountNotificationsPageState();
}

class _AccountNotificationsPageState extends State<AccountNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ScaffoldTitle('Notifications')),
      body: Material(
        child: ListView(children: [
          AccountListTile(
            title: 'Messages',
            trailing: Switch.adaptive(
              value: UserStore().user.getNotifSett(NotifType.Message),
              onChanged: (_) {
                UserStore().toggleNotificationSettings(NotifType.Message);
                setState(() => {});
              },
            ),
          ),
          AccountListTile(
            title: 'Matches',
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.Match),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.Match);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Views',
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.View),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.View);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Likes',
            withDivider: false,
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NotifType.Like),
                onChanged: (_) {
                  UserStore().toggleNotificationSettings(NotifType.Like);
                  setState(() => {});
                }),
          ),
        ]),
      ),
    );
  }
}
