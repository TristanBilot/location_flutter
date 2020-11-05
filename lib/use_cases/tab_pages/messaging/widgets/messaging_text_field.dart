import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_send_button.dart';
import 'package:location_project/widgets/basic_cupertino_text_field.dart';

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
          child: BasicCupertinoTextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
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
