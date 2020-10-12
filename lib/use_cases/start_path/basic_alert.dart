import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class BasicAlert extends StatelessWidget {
  final List<Widget> actions;
  final String title;
  final String content;

  BasicAlert(this.title, this.content, this.actions);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Theme.of(context).backgroundColor,
      title: TextSF(
        title,
        fontSize: 26,
        fontWeight: FontWeight.w600,
      ),
      content: TextSF(
        content,
        fontSize: 17,
      ),
      actions: actions,
    );
  }
}
