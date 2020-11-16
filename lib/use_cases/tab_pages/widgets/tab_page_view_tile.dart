import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/view.dart';
import 'package:location_project/use_cases/tab_pages/messaging/views/cubit/view_cubit.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_rich_text.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_slidable.dart';
import 'package:location_project/widgets/user_card.dart';
import 'package:location_project/widgets/user_map_card.dart';

/// Fetch a user from a user ID and display a tile.
class TabPageViewTile extends StatefulWidget {
  final View view;
  final bool shouldRefreshCache;

  const TabPageViewTile(
    this.view,
    this.shouldRefreshCache,
  );

  @override
  _TabPageViewTileState createState() => _TabPageViewTileState();
}

class _TabPageViewTileState extends State<TabPageViewTile> {
  Future<User> _fetchUser() async {
    final id = widget.view.id;
    bool useDatabase = !widget.shouldRefreshCache && Database().keyExists(id);
    return await UserRepository()
        .fetchUser(id, useDatabase: useDatabase, withBlocks: false);
  }

  _onTileTapped(BuildContext context, User user) {
    UserRepository().updateView(
        UserStore().user.id, UserField.UserIDsWhoWiewedMe, widget.view, true);
    UserMapCard(context, user, () async => {}).show(addViewToStore: false);
  }

  _onRemoveViewTap(String viewerID) {
    context.read<ViewCubit>().deleteView(viewerID);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data as User;
          final isViewUnread = !widget.view.isViewed;

          return GestureDetector(
            onTap: () => _onTileTapped(context, user),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    TabPageSlidable(
                      isOnlyOneAction: true,
                      action1: () => _onRemoveViewTap(user.id),
                      text1: 'Remove',
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              // display name and distance
                              child: TabPageRichText(
                                user.firstName,
                                user.distance,
                                isMsgUnread: isViewUnread,
                              ),
                            ),
                            isViewUnread
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
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
