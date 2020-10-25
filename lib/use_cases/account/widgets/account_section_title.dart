import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountSectionTitle extends StatelessWidget {
  final String title;

  const AccountSectionTitle(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.fromLTRB(20, 30, 0, 10),
      child: TextSF(
        title.toUpperCase(),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
