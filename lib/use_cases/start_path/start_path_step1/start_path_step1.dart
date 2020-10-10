import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';
import '../widgets/gender_circle_icon.dart';

class StartPathStep1 extends StatefulWidget {
  @override
  _StartPathStep1State createState() => _StartPathStep1State();
}

class _StartPathStep1State extends State<StartPathStep1> {
  double _sliderValue = 18;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
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
              GenderCircleIcon('💆‍♂️', 'Male'),
              Spacer(),
              GenderCircleIcon('🙋‍♀️', 'Female'),
              Spacer(),
              GenderCircleIcon('🤷', 'Other'),
              Spacer(),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 80, bottom: 30),
            child: TextSF(
              'What\'s your age ?',
              isTitle: true,
            ),
          ),
          Slider.adaptive(
            value: _sliderValue,
            min: 0,
            max: 80,
            // activeColor: _sliderValue >= 18
            //     ? Theme.of(context).sliderTheme.inactiveTrackColor
            //     : Colors.red[400],
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
          )
        ],
      ),
    );
  }
}
