import 'package:flutter/material.dart';
import 'package:location_project/use_cases/account/widgets/account_list_tile.dart';
import 'package:location_project/widgets/textSF.dart';

class AccountLanguagePage extends StatefulWidget {
  AccountLanguagePage({Key key}) : super(key: key);

  @override
  _AccountLanguagePageState createState() => _AccountLanguagePageState();
}

class _AccountLanguagePageState extends State<AccountLanguagePage> {
  final List<String> _languages = List.from(['French', 'English']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextSF(
        'Languages',
        fontSize: 16,
      )),
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
