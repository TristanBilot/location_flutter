import 'package:flutter/material.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/widgets/scaffold_title.dart';

enum Language { French, English }

class AccountLanguagePage extends StatefulWidget {
  AccountLanguagePage({Key key}) : super(key: key);

  @override
  _AccountLanguagePageState createState() => _AccountLanguagePageState();
}

class _AccountLanguagePageState extends State<AccountLanguagePage> {
  final List<String> _languages = ['French', 'English'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ScaffoldTitle('Languages')),
      body: Material(
        child: ListView(children: [
          AccountListTile(
            extraTopPadding: 10.0,
            title: _languages[0],
            trailing: Icon(Icons.done),
          ),
          AccountListTile(
            title: _languages[1],
            withDivider: false,
          )
        ]),
      ),
    );
  }
}
