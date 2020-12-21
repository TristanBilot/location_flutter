import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/conf/routes.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/user_mock_repository.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/edit%20profile/cubit/edit_profile_cubit.dart';
import 'package:location_project/use_cases/account/edit%20profile/profile_editing_page.dart';
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
  static const double PicSize = AccountPage.userImageSize;

  Set<Gender> _selectedGenders;
  AuthRepository _authRepo;
  Timer _sliderTimer;

  @override
  void initState() {
    _init();
    _authRepo = AuthRepository();
    super.initState();
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

  void _handleWantedAgeModify(
      List<double> wantedAgeValues, int index, double value) {
    setState(() => wantedAgeValues[index] = value);
    if (_sliderTimer != null) _sliderTimer.cancel();
    _sliderTimer = Timer(
        Duration(milliseconds: 500),
        () => UserStore()
            .setWantedAgeRange(wantedAgeValues.map((e) => e.round()).toList()));
  }

  Color _getHeaderBackground() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? DarkTheme.BackgroundLightColor : Colors.white;
  }

  _onPicturePress() async {
    // Animation.
    // setState(() => PicSize = AccountPage.userImageSize - 20);
    // await Future.delayed(Duration(milliseconds: AccountPage.picAnimDuration));
    // HapticFeedback.mediumImpact();
    // setState(() => PicSize = AccountPage.userImageSize);
    // await Future.delayed(Duration(milliseconds: AccountPage.picAnimDuration));

    // final pictureURL =
    //     await ImageRepository().pickImageAndUpload(UserStore().user.id);
    // if (pictureURL != null) {
    //   setState(
    //       () => UserStore().user.pictureURL = pictureURL); // modifier par liste
    // }
    _pushProfileEditingPageWithAnimation();
  }

  void _pushProfileEditingPageWithAnimation() {
    Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context2, animation, secondaryAnimation) =>
              ProfileEditingPage(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end);
            var curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final wantedAgeValues = UserStore()
        .user
        .settings
        .wantedAgeRange
        .map((e) => e.toDouble())
        .toList();

    _selectedGenders = UserStore().user.settings.wantedGenders.toSet();

    return Scaffold(
      body: Material(
        color: ThemeUtils.getListBackgroundColor(context),
        child: BlocListener<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state is DidEditProfileState) setState(() {});
          },
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
                        gradient: ThemeUtils.getResponsiveGradient(context),
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
                          width: PicSize,
                          height: PicSize,
                          duration: Duration(
                              milliseconds: AccountPage.picAnimDuration),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CachedCircleUserImage(
                                UserStore().user.mainPictureURL,
                                size: AccountPage.userImageSize,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, right: 6),
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
                            '${UserStore().user.firstName}, ${UserStore().user.age}',
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
                            '${wantedAgeValues[0].round()} - ${wantedAgeValues[1].round()}${wantedAgeValues[1].round() == Store.maxAgeRange ? "+" : ""} ',
                            color: MediaQuery.of(context).platformBrightness ==
                                    Brightness.light
                                ? Colors.black54
                                : Colors.white,
                          ),
                          bottom: Container(
                            width: MediaQuery.of(context).size.width -
                                2 * AccountListTile.SidePadding,
                            child: CupertinoRangeSlider(
                              activeColor: LogoOrangeColor,
                              minValue: wantedAgeValues[0],
                              maxValue: wantedAgeValues[1],
                              min: Store.minAgeRange,
                              max: Store.maxAgeRange,
                              onMinChanged: (value) => _handleWantedAgeModify(
                                  wantedAgeValues, 0, value),
                              onMaxChanged: (value) => _handleWantedAgeModify(
                                  wantedAgeValues, 1, value),
                            ),
                          ),
                        ),
                        AccountSectionTitle('Parameters'),
                        AccountListTile(
                          title: 'Show my profile',
                          trailing: Switch.adaptive(
                              value: UserStore().user.settings.showMyprofile,
                              onChanged: (newvalue) {
                                setState(() {
                                  UserStore().setShowMyProfile(newvalue);
                                });
                              }),
                        ),
                        AccountListTile(
                          title: 'Show my distance',
                          trailing: Switch.adaptive(
                              value: UserStore().user.settings.showMyDistance,
                              onChanged: (newvalue) {
                                setState(() {
                                  UserStore().setShowMyDistance(newvalue);
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
      ),
    );
  }
}
