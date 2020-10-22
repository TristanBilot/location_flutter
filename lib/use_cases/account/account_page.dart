import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:location_project/repositories/auth_repository.dart';
import 'package:location_project/repositories/user_mock_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_log_out_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_section_title.dart';
import 'package:location_project/use_cases/messaging/messaging_mock_repository.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/cupertino_range_slider.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountPage extends StatefulWidget {
  static const curveContainerHeight = 150.0;
  static const userImageSize = 130.0;

  AccountPage({Key key}) : super(key: key);

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

  AuthRepository _authRepo;

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: ListView(
          shrinkWrap: true,
          children: [
            Stack(children: [
              Container(
                height: AccountPage.curveContainerHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(
                        MediaQuery.of(context).size.width, 160.0),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: AccountPage.curveContainerHeight -
                        AccountPage.userImageSize / 2),
                child: Center(
                  child: CachedCircleUserImage(
                    UserStore().user.pictureURL,
                    size: AccountPage.userImageSize,
                  ),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextSF(
                    '$_name, $_age',
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ]..addAll([
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
                    onMinChanged: (value) => _handleWantedAgeModify(0, value),
                    onMaxChanged: (value) => _handleWantedAgeModify(1, value),
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
                        UserStore().setShowMyDistance(_isShowMyDistance);
                      });
                    }),
              ),
              AccountListTile(
                withDivider: false,
                title: 'App language',
                trailing: Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.languages.value),
              ),
              AccountLogOutListTile('LOG OUT',
                  color: Theme.of(context).primaryColor, onPressed: () {
                _authRepo.logOut().then((_) => Navigator.of(context)
                    .pushReplacementNamed(Routes.login.value));
              }),
              AccountLogOutListTile(
                'DELETE MY ACCOUNT',
                color: Colors.red[500],
                onPressed: () {
                  UserMockRepository().putParisDataset();
                  UserMockRepository().putCarrieresDataset();
                  // MessagingMockRepository().insertChatMock();
                  // MessagingMockRepository().insertMessageMock();
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: AccountLogOutListTile.Padding),
              )
            ]),
        ),
      ),
    );
  }
}
