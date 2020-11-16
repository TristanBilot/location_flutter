import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/focused_menu_holder.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/focused_menu_item.dart';

class MessageTileMenu extends StatefulWidget {
  final Widget child;
  final Message message;

  MessageTileMenu({
    @required this.message,
    @required this.child,
  });

  @override
  _MessageTileMenuState createState() => _MessageTileMenuState();
}

class _MessageTileMenuState extends State<MessageTileMenu> {
  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      onPressed: () => {},
      menuItems: [
        FocusedMenuItem(
            title: Text("Like"),
            trailingIcon: Icon(Icons.favorite_border),
            onPressed: () {}),
        FocusedMenuItem(
            title: Text("Copy"),
            trailingIcon: Icon(Icons.content_copy),
            onPressed: () {}),
        FocusedMenuItem(
            title: Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
            trailingIcon: Icon(
              Icons.delete_forever,
              color: Colors.redAccent,
            ),
            onPressed: () {}),
      ],
      child: widget.child,
    );
  }
}
