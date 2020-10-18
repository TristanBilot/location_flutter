import 'package:flutter/material.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/stores/start_path_store.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/widgets/textSF.dart';
import '../widgets/gender_circle_icon.dart';

/// Controller which can't deactivate all the
/// icons from an array of states.
mixin GenderIconController {
  void resetGenderCircleStates();
  void updateSelectedGender(Gender gender);
}

class StartPathStep1 extends StatefulWidget {
  static final allPadding = 30.0;
  static final nbOfSections = 4;

  @override
  StartPathStep1State createState() => StartPathStep1State();
}

class StartPathStep1State extends State<StartPathStep1>
    with GenderIconController {
  double _sliderValue = 20;
  List<GenderCircleIcon> _circleIcons;
  Gender _selectedGender;

  // GenderIconController implementation
  void resetGenderCircleStates() {
    GenderCircleIconState.resetGenderCircleStates(_circleIcons);
  }

  void updateSelectedGender(Gender gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  bool get _isPageValid => _selectedGender != null;

  @override
  void initState() {
    super.initState();

    _circleIcons = GenderCircleIconFactory().makeGenderIcons(this, null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(StartPathStep1.allPadding),
        child: Column(
          children: [
            Breadcrumb(1),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: TextSF(
                'Wait, who are you ?',
                isTitle: true,
              ),
            ),
            EquallySpacedRow(_circleIcons),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                children: [
                  Divider(),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: TextSF(
                'What\'s your age ?',
                isTitle: true,
              ),
            ),
            Row(
              children: [
                Spacer(),
                Slider(
                  value: _sliderValue,
                  min: 0,
                  max: 70,
                  label: _sliderValue.round().toString(),
                  onChanged: (value) => setState(() {
                    if (value < 18) return;
                    _sliderValue = value;
                  }),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.black12, width: 3.0)),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextSF(
                      _sliderValue.round().toString(),
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 20), child: Divider()),
            // Divider(),
            Spacer(),
            Spacer(),
            BasicButton(
              'ROUTE TO MAP',
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(Routes.map.value),
            ),
            BasicButton('NEXT', enabled: _isPageValid, onPressed: () {
              StartPathStore().setUserGender(_selectedGender);
              StartPathStore().setUserAge(_sliderValue.toInt());
              Navigator.of(context).pushNamed(Routes.startPathStep2.value);
            }),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
            )
          ],
        ),
      ),
    );
  }
}
