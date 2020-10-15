import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountSectionTitle extends StatelessWidget {
  final String title;

  const AccountSectionTitle(this.title, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
      child: TextSF(
        title.toUpperCase(),
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black38,
      ),
    );
  }
}
