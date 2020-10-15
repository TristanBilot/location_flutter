import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountListTile extends StatefulWidget {
  static const SidePadding = 20.0;
  final String title;
  final String substitle;
  final Widget trailing;
  final Widget leading;
  final Widget bottom;
  final bool withDivider;

  AccountListTile(
      {Key key,
      this.title,
      this.substitle,
      this.leading,
      this.trailing,
      this.bottom,
      this.withDivider = true})
      : super(key: key);

  @override
  _AccountListTileState createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.all(0),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(
              left: AccountListTile.SidePadding,
              right: AccountListTile.SidePadding,
            ),
            title: TextSF(widget.title),
            subtitle:
                widget.substitle != null ? TextSF(widget.substitle) : null,
            trailing: widget.trailing,
            leading: widget.leading,
          )
        ]
          /* all account parameters tiles */
          ..addAll(
            widget.bottom == null
                ? []
                : [
                    Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: widget.bottom,
                    ),
                  ],
          )
          /* divider or space to end the tile */
          ..add(
            widget.withDivider
                ? Container(child: Divider())
                : Container(padding: EdgeInsets.only(top: 10)),
          ),
      ),
    );
  }
}
