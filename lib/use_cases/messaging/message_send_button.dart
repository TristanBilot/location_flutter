import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MessageSendButton extends StatefulWidget {
  final Function onPressed;
  final bool activated;

  MessageSendButton({
    @required this.onPressed,
    @required this.activated,
  });

  @override
  _MessageSendButtonState createState() => _MessageSendButtonState();
}

class _MessageSendButtonState extends State<MessageSendButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: GestureDetector(
        onTap: widget.activated ? widget.onPressed : null,
        child: Container(
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: widget.activated
                  ? [Color(0xff007EF4), Color(0xff2A75BC)]
                  : [Color(0xFF999999), Color(0xFF777777)],
            ),
          ),
          child: Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}
