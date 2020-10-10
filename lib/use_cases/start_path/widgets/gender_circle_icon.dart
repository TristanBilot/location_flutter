import 'package:flutter/material.dart';
import 'package:location_project/use_cases/start_path/start_path_step1/start_path_step1.dart';
import 'package:location_project/widgets/textSF.dart';

enum Gender { Male, Female, Other }

class GenderCircleIcon extends StatefulWidget {
  final Gender gender;
  final String textIcon;
  final String testDescription;
  final GenderCircleIconState state;
  final GenderIconController controller;

  GenderCircleIcon(this.gender, this.textIcon, this.testDescription, this.state,
      this.controller);

  @override
  GenderCircleIconState createState() => state;
}

class GenderCircleIconState extends State<GenderCircleIcon> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
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
            widget.controller.resetGenderCircleStates();
            widget.controller.updateSelectedGender(widget.gender);
            setState(() {
              isSelected = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black12,
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
    ;
  }
}
