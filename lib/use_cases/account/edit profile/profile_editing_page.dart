import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/edit%20profile/draggable_image_collection.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'dart:math' as math;

class ProfileEditingPage extends StatefulWidget {
  final int depth;
  const ProfileEditingPage({this.depth = 100});

  @override
  _ProfileEditingPageState createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {
  static const int NbMaxUserPictures = 6;

  final String _mainUserPictureURL;

  _ProfileEditingPageState()
      : _mainUserPictureURL = UserStore().user.mainPictureURL;

  List<String> get _pictureURLsWithAddButton {
    return [
      ...UserStore().user.pictureURLs,
      ...[DraggableImageCollection.AddButtonKey]
    ];
  }

  _checkIfMainPictureChanged() async {}

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              automaticallyImplyLeading: false,
              trailing: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Done',
                    style: TextStyle(color: CupertinoColors.activeBlue)),
              ),
              largeTitle: Text(
                'Edit profile',
                style: TextStyle(
                    color: ThemeUtils.getBlackIfLightAndWhiteIfDark(context)),
              ),
            )
          ];
        },
        body: DraggableImageCollection(
            _pictureURLsWithAddButton, NbMaxUserPictures),
      ),
    );
  }
}
