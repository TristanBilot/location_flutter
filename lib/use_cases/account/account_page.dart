import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user_mock_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_log_out_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_section_title.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_mock_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/utils/toaster/message_toaster.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/cupertino_range_slider.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/models/gender.dart';

class AccountPage extends StatefulWidget {
  static const curveContainerHeight = 100.0;
  static const userImageSize = 150.0;
  static const picAnimDuration = 100;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with GenderMultiIconController {
  List<GenderCircleIcon> _circleIcons;
  HashSet<Gender> _selectedGenders;

  bool _isShowMyProfile;
  bool _isShowMyDistance;
  List<double> _wantedAgeValues;
  String _name;
  int _age;
  double _picSize = AccountPage.userImageSize;

  AuthRepository _authRepo;

  @override
  void initState() {
    UserStore().enableMessageNotif();
    super.initState();

    _circleIcons = GenderCircleIconFactory().makeGenderIcons(null, this);
    _selectedGenders = HashSet();
    _authRepo = AuthRepository();
    _loadUserData();
  }

  @override
  void iconDidSelected(Gender gender, bool isSelected) {
    setState(() {
      if (isSelected)
        _selectedGenders.add(gender);
      else
        _selectedGenders.remove(gender);
      UserStore().setWantedGenders(_selectedGenders.toList());
    });
  }

  _loadUserData() {
    _isShowMyProfile = UserStore().user.settings.showMyprofile;
    _isShowMyDistance = UserStore().user.settings.showMyDistance;
    _wantedAgeValues = UserStore()
        .user
        .settings
        .wantedAgeRange
        .map((e) => e.toDouble())
        .toList();
    _name = UserStore().user.firstName;
    _age = UserStore().user.age;
    /* need to load after build() are the icons are not created yet */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _circleIcons.forEach((icon) {
        if (UserStore().user.settings.wantedGenders.contains(icon.gender)) {
          icon.state.setState(() => icon.state.isSelected = true);
          _selectedGenders.add(icon.gender);
        }
      });
    });
  }

  void _handleWantedAgeModify(int index, double value) {
    setState(() {
      _wantedAgeValues[index] = value;
      UserStore()
          .setWantedAgeRange(_wantedAgeValues.map((e) => e.round()).toList());
    });
  }

  Color _getCurveContainerBackground() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark
        ? Color.fromRGBO(40, 40, 40, 1)
        : Color.fromRGBO(240, 240, 240, 1);
  }

  Color _getHeaderBackground() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Color.fromRGBO(66, 66, 66, 1) : Colors.white;
  }

  _onPicturePress() async {
    // Animation.
    setState(() => _picSize = AccountPage.userImageSize - 20);
    await Future.delayed(Duration(milliseconds: AccountPage.picAnimDuration));
    HapticFeedback.mediumImpact();
    setState(() => _picSize = AccountPage.userImageSize);
    await Future.delayed(Duration(milliseconds: AccountPage.picAnimDuration));

    final success =
        await ImageRepository().pickImageAndUpload(UserStore().user.id);
    if (success) {
      final newURL =
          await ImageRepository().getPictureDownloadURL(UserStore().user.id);
      setState(() => UserStore().user.pictureURL = newURL);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              // pinned: true,
              expandedHeight: 200,
              // title: Text('Title'),
              backgroundColor: _getHeaderBackground(),
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(children: [
                  Container(
                    height: AccountPage.curveContainerHeight,
                    decoration: BoxDecoration(
                      color: _getCurveContainerBackground(),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width, 160.0),
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: _onPicturePress,
                      child: AnimatedContainer(
                        width: _picSize,
                        height: _picSize,
                        duration:
                            Duration(milliseconds: AccountPage.picAnimDuration),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            CachedCircleUserImage(
                              UserStore().user.pictureURL,
                              size: AccountPage.userImageSize,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 6),
                              child: Container(
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    color: _getHeaderBackground(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: TextSF(
                          '$_name, $_age',
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ]..addAll(
                    [
                      AccountSectionTitle('I\'m looking for'),
                      AccountListTile(
                        title: 'Gender',
                        bottom: EquallySpacedRow(_circleIcons),
                      ),
                      AccountListTile(
                        withDivider: false,
                        title: 'Age range',
                        trailing: TextSF(
                            '${_wantedAgeValues[0].round()}-${_wantedAgeValues[1].round()} years old'),
                        bottom: Container(
                          width: MediaQuery.of(context).size.width -
                              2 * AccountListTile.SidePadding,
                          child: CupertinoRangeSlider(
                            minValue: _wantedAgeValues[0],
                            maxValue: _wantedAgeValues[1],
                            min: 18,
                            max: 70,
                            onMinChanged: (value) =>
                                _handleWantedAgeModify(0, value),
                            onMaxChanged: (value) =>
                                _handleWantedAgeModify(1, value),
                          ),
                        ),
                      ),
                      AccountSectionTitle('Parameters'),
                      AccountListTile(
                        title: 'Show my profile',
                        trailing: Switch.adaptive(
                            value: _isShowMyProfile,
                            onChanged: (newvalue) {
                              setState(() {
                                _isShowMyProfile = newvalue;
                                UserStore().setShowMyProfile(_isShowMyProfile);
                              });
                            }),
                      ),
                      AccountListTile(
                        title: 'Show my distance',
                        trailing: Switch.adaptive(
                            value: _isShowMyDistance,
                            onChanged: (newvalue) {
                              setState(() {
                                _isShowMyDistance = newvalue;
                                UserStore()
                                    .setShowMyDistance(_isShowMyDistance);
                              });
                            }),
                      ),
                      AccountListTile(
                        withDivider: false,
                        title: 'App language',
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.languages.value),
                      ),
                      AccountListTile(
                        withDivider: false,
                        title: 'Blocked users',
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.blockedUsers.value),
                      ),
                      AccountLogOutListTile('LOG OUT', onPressed: () {
                        _authRepo.logOut().then((_) => Navigator.of(context)
                            .pushReplacementNamed(Routes.login.value));
                      }),
                      AccountLogOutListTile(
                        'DELETE MY ACCOUNT',
                        color: Colors.red[500],
                        onPressed: () {
                          UserMockRepository().putParisDataset();
                          UserMockRepository().putCarrieresDataset();
                          MessagingMockRepository().insertChatMock().then(
                              (value) => MessagingMockRepository()
                                  .insertMessageMock());
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: AccountLogOutListTile.Padding),
                      ),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
