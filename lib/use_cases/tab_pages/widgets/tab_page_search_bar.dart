import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/basic_cupertino_text_field.dart';

class SearchBar extends StatefulWidget {
  final TextEditingController messageEditingController;

  SearchBar({
    @required this.messageEditingController,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  @override
  Widget build(BuildContext context) {
    return BasicCupertinoTextField(
      controller: widget.messageEditingController,
      // onChanged: (text) => widget.setStateDelegate.setStateFromOutside(),
      maxLines: 1,
      placeholder: 'Search',
      clearButtonMode: OverlayVisibilityMode.editing,
      autoCorrect: false,
      enableSuggestions: false,
      leadingWidget: Padding(
        padding: const EdgeInsets.only(left: 7),
        child: Icon(Icons.search),
      ),
    );
  }
}
