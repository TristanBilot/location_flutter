import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountBlockedUsersPage extends StatefulWidget {
  AccountBlockedUsersPage({Key key}) : super(key: key);

  @override
  _AccountBlockedUsersPageState createState() =>
      _AccountBlockedUsersPageState();
}

class _AccountBlockedUsersPageState extends State<AccountBlockedUsersPage> {
  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  _fetchBlockedIDsAndUsers() async {
    final id = UserStore().user.id;
    final blockIDs = await UserRepository()
        .getCollectionSnapshot(id, UserField.BlockedUserIDs);
    final blockedUsers = blockIDs.docs.map((doc) =>
        UserRepository().fetchUser(doc.id, useCache: true, withViews: false));
    return Future.wait(blockedUsers);
  }

  Future<void> _onUnblockTap(String blockedID) async {
    UserStore().deleteBlockedUser(blockedID).then((value) async {
      HapticFeedback.mediumImpact();
      await Future.delayed(Duration(milliseconds: 200));

      setStateIfMounted(() {});
      Logger().i("$blockedID unblocked successfuly.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextSF(
        'Blocked users',
        fontSize: 16,
      )),
      body: Material(
        child: FutureBuilder(
          future: _fetchBlockedIDsAndUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final blockedUsers = snapshot.data;
              if (blockedUsers.length == 0)
                return BasicPlaceholder('Nobody blocked yet.');
              return ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final blockedUser = blockedUsers[index] as User;
                    return AccountListTile(
                      withDivider: false,
                      title: blockedUser.firstName,
                      trailing: BasicButton(
                        'Unblock',
                        fontsSize: 12,
                        onPressed: () => _onUnblockTap(blockedUser.id),
                      ),
                      leading: CachedCircleUserImage(
                        blockedUser.pictureURL,
                        size: 45,
                        withBorder: false,
                      ),
                    );
                  });
            }
            return Container();
          },
        ),
      ),
    );
  }
}
