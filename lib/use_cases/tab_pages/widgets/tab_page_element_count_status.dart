import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      width: MediaQuery.of(context).size.width / 3.4,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: TextSF(widget.title),
          ),
          widget.nbElements != null && widget.nbElements != 0
              ? Align(
                  alignment: Alignment.topRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 22,
                        width: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      TextSF(
                        '${widget.nbElements}',
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
