import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicCupertinoTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final String placeholder;
  final OverlayVisibilityMode clearButtonMode;
  final Widget leadingWidget;
  final bool autoCorrect;
  final bool enableSuggestions;

  BasicCupertinoTextField({
    @required this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.multiline,
    this.maxLines,
    this.placeholder = 'Message',
    this.clearButtonMode = OverlayVisibilityMode.never,
    this.leadingWidget,
    this.autoCorrect = true,
    this.enableSuggestions = true,
  });

  @override
  _BasicCupertinoTextFieldState createState() =>
      _BasicCupertinoTextFieldState();
}

class _BasicCupertinoTextFieldState extends State<BasicCupertinoTextField> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
      controller: widget.controller,
      onChanged: widget.onChanged,
      style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
      clearButtonMode: widget.clearButtonMode,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Colors.grey[500], width: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      placeholder: widget.placeholder,
      prefix: widget.leadingWidget,
      autocorrect: widget.autoCorrect,
      enableSuggestions: widget.enableSuggestions,
    );
  }
}
