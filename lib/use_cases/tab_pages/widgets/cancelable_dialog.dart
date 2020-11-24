import 'package:flutter/material.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';

class CancelableDialog extends StatefulWidget {
  final String title;
  final BasicAlertButton otherButton;
  final BuildContext context;

  const CancelableDialog(this.context, this.title, this.otherButton);

  void show() {
    showDialog(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  _CancelableDialogState createState() => _CancelableDialogState();
}

class _CancelableDialogState extends State<CancelableDialog> {
  Color cancelButtonColor() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark
        ? Color.fromRGBO(60, 60, 60, 1)
        : Color.fromRGBO(140, 140, 140, 1);
  }

  void _onCancelPress() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return BasicAlert(
      widget.title,
      titleFontSize: 18,
      titleAlignment: TextAlign.center,
      contentPadding: EdgeInsets.only(bottom: 10),
      actions: [
        BasicAlertButton('CANCEL', _onCancelPress, color: cancelButtonColor()),
        widget.otherButton,
      ],
    );
  }
}
