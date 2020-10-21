import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagingTextField extends StatefulWidget {
  final TextEditingController controller;
  final Function onPressed;

  MessagingTextField({
    @required this.controller,
    @required this.onPressed,
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
            style:
                TextStyle(color: Theme.of(context).textTheme.headline6.color),
            // clearButtonMode: OverlayVisibilityMode.editing,
            cursorColor: Colors.white,
            controller: widget.controller,
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
        FlatButton(
          onPressed: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Icon(Icons.send, size: 20),
          ),
        ),
      ],
    );
  }
}
