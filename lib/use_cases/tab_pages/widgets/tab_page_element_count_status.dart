import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_status_with_count.dart';
import 'package:location_project/widgets/textSF.dart';

class TabPageElementCountStatus extends StatefulWidget {
  final String title;
  final int nbElements;

  TabPageElementCountStatus(this.title, this.nbElements);

  @override
  _TabPageElementCountStatusState createState() =>
      _TabPageElementCountStatusState();
}

class _TabPageElementCountStatusState extends State<TabPageElementCountStatus> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.6,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: TextSF(
              widget.title,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          widget.nbElements != null && widget.nbElements != 0
              ? Align(
                  alignment: Alignment.topRight,
                  child: TabPageStatusWithCount(widget.nbElements))
              : SizedBox(),
        ],
      ),
    );
  }
}
