import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class TabPagePlaceholer extends StatelessWidget {
  final String message;

  const TabPagePlaceholer(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextSF(
        message,
        fontSize: 18,
        color: Colors.grey,
      ),
    );
  }
}
