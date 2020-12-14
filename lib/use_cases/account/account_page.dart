import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/conf/routes.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/image_repository.dart';
import 'package:location_project/repositories/user_mock_repository.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_log_out_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_section_title.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card_delegate.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_mock_repository.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/cupertino_range_slider.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/models/gender.dart';

class AccountPage extends StatefulWidget {
  static const curveContainerHeight = 150.0;
  static const userImageSize = 150.0;
  static const picAnimDuration = 100;

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with SelectableSmallCardDelegate {
  Set<Gender> _selectedGenders;
  bool _isShowMyProfile;
  bool _isShowMyDistance;
  List<double> _wantedAgeValues;
  String _name;
  int _age;
  double _picSize = AccountPage.userImageSize;

  AuthRepository _authRepo;

  @override
  void initState() {
    _init();
    super.initState();

    _selectedGenders = Set();
    _authRepo = AuthRepository();
    _loadUserData();
  }

  void _init() {
    MemoryStore().setDisplayToastValues(true, true, true, true, '');
  }

  void toggle(Gender enumType, bool isSelected) {
    setState(() {
      if (isSelected)
        _selectedGenders.add(enumType);
      else
        _selectedGenders.remove(enumType);
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
    _selectedGenders = UserStore().user.settings.wantedGenders.toSet();
  }

  void _handleWantedAgeModify(int index, double value) {
    setState(() {
      _wantedAgeValues[index] = value;
      UserStore()
          .setWantedAgeRange(_wantedAgeValues.map((e) => e.round()).toList());
    });
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
        color: ThemeUtils.getListBackgroundColor(context),
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
                      gradient: AppGradient,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(
                            MediaQuery.of(context).size.width, 100.0),
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
                        bottom: Padding(
                          padding: const EdgeInsets.only(
                              left: AccountListTile.SidePadding),
                          child: Row(children: [
                            SelectableSmallCard(Gender.Female, this,
                                _selectedGenders.contains(Gender.Female)),
                            SelectableSmallCard(Gender.Male, this,
                                _selectedGenders.contains(Gender.Male)),
                            SelectableSmallCard(Gender.Other, this,
                                _selectedGenders.contains(Gender.Other)),
                          ]),
                        ),
                      ),
                      AccountListTile(
                        withDivider: false,
                        title: 'Age range',
                        trailing: TextSF(
                          '${_wantedAgeValues[0].round()} - ${_wantedAgeValues[1].round()}${_wantedAgeValues[1].round() == Store.maxAgeRange ? "+" : ""} ',
                          color: Colors.black54,
                        ),
                        bottom: Container(
                          width: MediaQuery.of(context).size.width -
                              2 * AccountListTile.SidePadding,
                          child: CupertinoRangeSlider(
                            activeColor: LogoOrangeColor,
                            minValue: _wantedAgeValues[0],
                            maxValue: _wantedAgeValues[1],
                            min: Store.minAgeRange,
                            max: Store.maxAgeRange,
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
                        title: 'App language',
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.languages.value),
                      ),
                      AccountListTile(
                        title: 'Blocked users',
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.blockedUsers.value),
                      ),
                      AccountListTile(
                        withDivider: false,
                        title: 'Notifications',
                        trailing: Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context)
                            .pushNamed(Routes.notifications.value),
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
