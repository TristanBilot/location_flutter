import 'package:flutter/material.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
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
    _circleIcons.forEach((icon) => icon.state.setState(() {
          icon.state.isSelected = false;
        }));
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

    _circleIcons = [
      GenderCircleIcon(
          Gender.Male, '💆‍♂️', 'Male', GenderCircleIconState(), this, null),
      GenderCircleIcon(Gender.Female, '🙋‍♀️', 'Female',
          GenderCircleIconState(), this, null),
      GenderCircleIcon(
          Gender.Other, '🤷', 'Other', GenderCircleIconState(), this, null)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(StartPathStep1.allPadding),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30),
            child: TextSF(
              'Wait, who are you ?',
              isTitle: true,
            ),
          ),
          Row(
            children: [
              Spacer(),
              _circleIcons[0],
              Spacer(),
              _circleIcons[1],
              Spacer(),
              _circleIcons[2],
              Spacer(),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 40, bottom: 40),
            child: Column(
              children: [
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: TextSF(
              'What\'s your age ?',
              isTitle: true,
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 30),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black12, width: 3.0)),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: TextSF(
                  _sliderValue.round().toString(),
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Divider(),
          Spacer(),
          BasicButton('NEXT',
              enabled: _isPageValid,
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.startPathStep2.value)),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
          )
        ],
      ),
    );
  }
}
