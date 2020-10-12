import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:location_project/stores/routes.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/widgets/textSF.dart';
import '../widgets/gender_circle_icon.dart';

mixin GenderMultiIconController {
  void iconDidSelected(Gender gender, bool isSelected);
}

class StartPathStep2 extends StatefulWidget {
  @override
  StartPathStep2State createState() => StartPathStep2State();
}

class StartPathStep2State extends State<StartPathStep2>
    with GenderMultiIconController {
  RangeValues _sliderRangeValues = const RangeValues(18, 30);
  List<GenderCircleIcon> _circleIcons;
  HashSet<Gender> _selectedGenders;

  // GenderMultiIconController implementation
  void iconDidSelected(Gender gender, bool isSelected) {
    setState(() {
      if (isSelected)
        _selectedGenders.add(gender);
      else
        _selectedGenders.remove(gender);
    });
  }

  bool get _isPageValid => _selectedGenders.length != 0;

  @override
  void initState() {
    super.initState();

    _circleIcons = [
      GenderCircleIcon(
          Gender.Male, '💆‍♂️', 'Male', GenderCircleIconState(), null, this),
      GenderCircleIcon(Gender.Female, '🙋‍♀️', 'Female',
          GenderCircleIconState(), null, this),
      GenderCircleIcon(
          Gender.Other, '🤷', 'Other', GenderCircleIconState(), null, this)
    ];
    _selectedGenders = HashSet();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(StartPathStep1.allPadding),
        child: Column(
          children: [
            Breadcrumb(2),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: TextSF(
                'Now, who are you looking for ?',
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
                'Which range are you interesting in ?',
                isTitle: true,
              ),
            ),
            RangeSlider(
              values: _sliderRangeValues,
              min: 0,
              max: 70,
              onChanged: (values) => setState(() {
                if (values.start < 18 || values.end < 18) return;
                if (values.end - values.start < 5) return;
                _sliderRangeValues = values;
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
                    '${_sliderRangeValues.start.round()}-${_sliderRangeValues.end.round()}',
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
                onPressed: () => Navigator.of(context)
                    .pushNamed(Routes.startPathStep3.value)),
            Padding(
              padding: EdgeInsets.only(bottom: 50),
            )
          ],
        ),
      ),
    );
  }
}
