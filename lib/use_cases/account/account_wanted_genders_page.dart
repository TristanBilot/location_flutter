import 'package:flutter/material.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card_delegate.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/widgets/scaffold_title.dart';

class AccountWantedGendersPage extends StatefulWidget {
  final Set<Gender> selectedGenders;
  final GenderSmallCardDelegate delegate;

  const AccountWantedGendersPage(this.selectedGenders, this.delegate);

  @override
  _AccountWantedGendersPageState createState() =>
      _AccountWantedGendersPageState();
}

class _AccountWantedGendersPageState extends State<AccountWantedGendersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScaffoldTitle('Show me these genders'),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 30),
        child: EquallySpacedRow([
          GenderSmallCard(
              Gender.Female,
              widget.delegate,
              widget.selectedGenders.contains(
                Gender.Female,
              )),
          GenderSmallCard(
            Gender.Male,
            widget.delegate,
            widget.selectedGenders.contains(Gender.Male),
          ),
          GenderSmallCard(
            Gender.Other,
            widget.delegate,
            widget.selectedGenders.contains(Gender.Other),
          ),
        ]),
      ),
    );
  }
}
