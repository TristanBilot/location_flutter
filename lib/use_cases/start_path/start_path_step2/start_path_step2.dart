import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location_project/conf/routes.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/storage/memory/start_path_store.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/widgets/textSF.dart';
import '../widgets/gender_circle_icon.dart';
import 'package:location_project/models/gender.dart';

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

    _circleIcons = GenderCircleIconFactory().makeGenderIcons(null, this);
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
            EquallySpacedRow(_circleIcons),
            Spacer(),
            Divider(),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 0),
              child: TextSF(
                'Which range are you interesting in ?',
                isTitle: true,
              ),
            ),
            Row(
              children: [
                Spacer(),
                RangeSlider(
                  values: _sliderRangeValues,
                  min: Store.minAgeRange,
                  max: Store.maxAgeRange,
                  onChanged: (values) => setState(() {
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
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        style: TextSF.TextSFStyle.copyWith(
                            fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),

            // Divider(),
            Spacer(),
            BasicButton(
              'NEXT',
              enabled: _isPageValid,
              width: MediaQuery.of(context).size.width,
              onPressed: () {
                StartPathStore().setWantedAgeRange(List<int>.from([
                  _sliderRangeValues.start.toInt(),
                  _sliderRangeValues.end.toInt()
                ]));
                StartPathStore().setWantedGender(_selectedGenders);
                Navigator.of(context).pushNamed(Routes.startPathStep3.value);
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
            )
          ],
        ),
      ),
    );
  }
}
