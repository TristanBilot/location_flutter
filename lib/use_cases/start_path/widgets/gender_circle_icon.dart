import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/use_cases/start_path/start_path_step2/start_path_step2.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/models/gender.dart';

class GenderCircleIcon extends StatefulWidget {
  final Gender gender;
  final String textIcon;
  final String testDescription;
  final GenderCircleIconState state;
  final GenderIconController controller;
  final GenderMultiIconController multiController;

  GenderCircleIcon(this.gender, this.textIcon, this.testDescription, this.state,
      this.controller, this.multiController);

  @override
  GenderCircleIconState createState() => state;
}

class GenderCircleIconState extends State<GenderCircleIcon> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
  }

  static void resetGenderCircleStates(List<GenderCircleIcon> _circleIcons) {
    _circleIcons.forEach((icon) => icon.state.setState(() {
          icon.state.isSelected = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RawMaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          shape: CircleBorder(),
          elevation: 1.0,
          onPressed: () {
            if (widget.controller != null) {
              widget.controller.resetGenderCircleStates();
              widget.controller.updateSelectedGender(widget.gender);
              setState(() {
                isSelected = true;
              });
            } else if (widget.multiController != null) {
              setState(() {
                isSelected = !isSelected;
              });
              widget.multiController.iconDidSelected(widget.gender, isSelected);
            }
            HapticFeedback.heavyImpact();
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? PrimaryColor : Colors.black12,
                width: 2.0,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Text(
                widget.textIcon,
                style: TextStyle(fontSize: 60),
              ),
            ),
          ),
        ),
        TextSF(widget.testDescription),
      ],
    );
  }
}
