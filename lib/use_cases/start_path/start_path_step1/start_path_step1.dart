import 'package:flutter/material.dart';
import '../widgets/gender_circle_icon.dart';

class StartPathStep1 extends StatefulWidget {
  @override
  _StartPathStep1State createState() => _StartPathStep1State();
}

class _StartPathStep1State extends State<StartPathStep1> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GenderCircleIcon('💆‍♂️', 'Male'),
        GenderCircleIcon('🙋‍♀️', 'Female'),
        GenderCircleIcon('🤷', 'Other'),
      ],
    );
  }
}
