import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_chats_requests_page.dart';
import 'package:location_project/widgets/basic_cupertino_text_field.dart';

class TabPageSearchBar extends StatefulWidget {
  final TextEditingController messageEditingController;
  final SetStateDelegate setStateDelegate;

  TabPageSearchBar({
    @required this.messageEditingController,
    @required this.setStateDelegate,
  });

  @override
  _TabPageSearchBarState createState() => _TabPageSearchBarState();
}

class _TabPageSearchBarState extends State<TabPageSearchBar> {
  @override
  Widget build(BuildContext context) {
    return BasicCupertinoTextField(
      controller: widget.messageEditingController,
      onChanged: (text) => widget.setStateDelegate.setStateFromOutside(),
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
