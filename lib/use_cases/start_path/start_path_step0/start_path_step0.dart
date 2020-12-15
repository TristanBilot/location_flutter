import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/conf/routes.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/helpers/icon_picker.dart';
import 'package:location_project/storage/memory/start_path_store.dart';
import 'package:location_project/use_cases/start_path/gender_circle_icon_factory.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/breadcrumb.dart';
import 'package:location_project/use_cases/start_path/widgets/equally_spaced_row.dart';
import 'package:location_project/widgets/textSF.dart';
import '../widgets/gender_circle_icon.dart';
import 'package:location_project/models/gender.dart';

class StartPathStep0 extends StatefulWidget {
  static final allPadding = 30.0;
  static final nbOfSections = 4;

  @override
  StartPathStep0State createState() => StartPathStep0State();
}

class StartPathStep0State extends State<StartPathStep0> {
  TextEditingController _textController;
  TextEditingController _mailController;
  List<File> _pictures;

  @override
  void initState() {
    _textController = TextEditingController();
    _mailController = TextEditingController();
    _pictures = List();
    super.initState();
  }

  _onAddPictureTap() async {
    final File pickedImage = await IconPicker().pickImageFromGalery();
    if (pickedImage == null) return;
    _pictures.add(pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.all(StartPathStep0.allPadding),
        child: Column(
          children: [
            Breadcrumb(0),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: TextSF(
                'What\'s your name?',
                isTitle: true,
              ),
            ),
            SizedBox(height: 20),
            CupertinoTextField(controller: _textController),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: TextSF(
                'What\'s your email?',
                isTitle: true,
              ),
            ),
            SizedBox(height: 20),
            CupertinoTextField(controller: _mailController),
            BasicButton(
              'ADD PICTURE',
              width: MediaQuery.of(context).size.width,
              onPressed: () => _onAddPictureTap(),
            ),
            BasicButton(
              'NEXT',
              width: MediaQuery.of(context).size.width,
              onPressed: () {
                StartPathStore().setPictures(_pictures);
                StartPathStore().setName(_textController.text);
                StartPathStore().setEmailAndID(_mailController.text);
                Navigator.of(context).pushNamed(Routes.startPathStep1.value);
              },
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
            )
          ],
        ),
      ),
    );
  }
}
