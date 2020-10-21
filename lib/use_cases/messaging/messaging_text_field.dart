import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/use_cases/messaging/message_send_button.dart';

class MessagingTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function onPressed;
  final Function(String) onChanged;

  MessagingTextField({
    @required this.controller,
    @required this.onPressed,
    @required this.onChanged,
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
            padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
            controller: widget.controller,
            onChanged: widget.onChanged,
            style:
                TextStyle(color: Theme.of(context).textTheme.headline6.color),
            // clearButtonMode: OverlayVisibilityMode.editing,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border.all(color: Colors.grey[500], width: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            placeholder: 'Message',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: MessageSendButton(
            onPressed: widget.onPressed,
            activated: widget.controller.text != '',
          ),
        ),
      ],
    );
  }
}
