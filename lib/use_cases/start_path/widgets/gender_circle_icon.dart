import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class GenderCircleIcon extends StatefulWidget {
  final String textIcon;
  final String testDescription;

  GenderCircleIcon(this.textIcon, this.testDescription);

  @override
  _GenderCircleIconState createState() => _GenderCircleIconState();
}

class _GenderCircleIconState extends State<GenderCircleIcon> {
  bool _isSelected;

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
          onPressed: () => null,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black12,
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
