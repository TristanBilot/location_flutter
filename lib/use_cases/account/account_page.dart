import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_log_out_list_tile.dart';
import 'package:location_project/use_cases/account/widgets/account_section_title.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/use_cases/start_path/widgets/gender_circle_icon.dart';
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

  @override
  void initState() {
    super.initState();

    _circleIcons = GenderCircleIconFactory().makeGenderIcons(null, this);
    _selectedGenders = HashSet();
  }

  @override
  void iconDidSelected(Gender gender, bool isSelected) {
    setState(() {
      if (isSelected)
        _selectedGenders.add(gender);
      else
        _selectedGenders.remove(gender);
      UserStore.instance.setWantedGenders(_selectedGenders.toList());
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
                  child: Container(
                    width: AccountPage.userImageSize,
                    height: AccountPage.userImageSize,
                    child: CircleAvatar(
                      //UserCache.getLoggedUser.pictureURL ??
                      backgroundImage: NetworkImage(
                          'https://via.placeholder.com/300/09f/fff.png'),
                    ),
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
                    'Tristan, 21',
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
                trailing: TextSF('18-25 years old'),
                bottom: Container(
                  width: MediaQuery.of(context).size.width -
                      2 * AccountListTile.SidePadding,
                  child: CupertinoRangeSlider(
                    minValue: 20,
                    maxValue: 30,
                    min: 18,
                    max: 70,
                    onMinChanged: (value) => {},
                    onMaxChanged: (value) => {},
                  ),
                ),
              ),
              AccountSectionTitle('Parameters'),
              AccountListTile(
                title: 'Show my profile',
                trailing:
                    Switch.adaptive(value: true, onChanged: (newvalue) => null),
              ),
              AccountListTile(
                title: 'Show my distance',
                trailing:
                    Switch.adaptive(value: true, onChanged: (newvalue) => null),
              ),
              AccountListTile(
                title: 'App language',
                trailing: Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.languages.value),
              ),
              AccountLogOutListTile(
                'LOG OUT',
                color: Theme.of(context).primaryColor,
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(Routes.login.value),
              ),
              AccountLogOutListTile(
                'DELETE MY ACCOUNT',
                color: Colors.red[500],
                onPressed: () => UserStore.instance
                    .setWantedAgeRange(List<int>.from([10, 12])),
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
