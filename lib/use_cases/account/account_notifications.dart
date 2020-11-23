import 'package:flutter/material.dart';
import 'package:location_project/models/user_settings.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
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
              value: UserStore().user.getNotifSett(NofifSettingsField.Messages),
              onChanged: (_) {
                UserStore()
                    .toggleNotificationSettings(NofifSettingsField.Messages);
                setState(() => {});
              },
            ),
          ),
          AccountListTile(
            title: 'Conversations',
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NofifSettingsField.Chats),
                onChanged: (_) {
                  UserStore()
                      .toggleNotificationSettings(NofifSettingsField.Chats);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Requests',
            trailing: Switch.adaptive(
                value:
                    UserStore().user.getNotifSett(NofifSettingsField.Requests),
                onChanged: (_) {
                  UserStore()
                      .toggleNotificationSettings(NofifSettingsField.Requests);
                  setState(() => {});
                }),
          ),
          AccountListTile(
            title: 'Profile views',
            withDivider: false,
            trailing: Switch.adaptive(
                value: UserStore().user.getNotifSett(NofifSettingsField.Views),
                onChanged: (_) {
                  UserStore()
                      .toggleNotificationSettings(NofifSettingsField.Views);
                  setState(() => {});
                }),
          ),
        ]),
      ),
    );
  }
}