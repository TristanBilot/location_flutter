import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/scrollable_textview.dart';

class MessagingTextField extends StatefulWidget {
  final TextEditingController controller;

  MessagingTextField({
    @required this.controller,
  });

  @override
  _MessagingTextFieldState createState() => _MessagingTextFieldState();
}

class _MessagingTextFieldState extends State<MessagingTextField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextField(
            controller: widget.controller,
            // onSubmitted: onTextSubmitted,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(color: Colors.grey[500], width: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            placeholder: 'Message',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Icon(Icons.send, size: 20),
        ),
      ],
    );
  }
}
