import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/edit%20profile/draggable_image_collection.dart';
import 'package:location_project/widgets/textSF.dart';

class ProfileEditingPage extends StatefulWidget {
  @override
  _ProfileEditingPageState createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {
  static const int NbMaxUserPictures = 6;
  static const HPadding = 20.0;
  static const VPadding = 5.0;

  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _initBioTextField();
  }

  void _initBioTextField() {
    final initialBio = UserStore().user.bio;
    print(UserStore().user.bio);
    _textController = TextEditingController(text: initialBio);
  }

  List<String> get _pictureURLsWithAddButton {
    return [
      ...UserStore().user.pictureURLs,
      ...[DraggableImageCollection.AddButtonKey]
    ];
  }

  Widget get _picturesWidget =>
      DraggableImageCollection(_pictureURLsWithAddButton, NbMaxUserPictures);

  Widget get _bioWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: HPadding, bottom: VPadding),
            child: TextSF(
              'Bio',
              fontWeight: FontWeight.w500,
              fontSize: 17,
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(
                left: HPadding, right: HPadding, top: 3, bottom: 3),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              keyboardType: TextInputType.multiline,
              controller: _textController,
              maxLines: null,
              maxLength: 500,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
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
              ),
            ];
          },
          body: Container(
            child: Column(
              children: [
                _picturesWidget,
                SizedBox(height: 10),
                _bioWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
