import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/conf/store.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/account/edit%20profile/cubit/edit_profile_cubit.dart';
import 'package:location_project/use_cases/account/edit%20profile/draggable_image_collection.dart';
import 'package:location_project/use_cases/account/widgets/account_subtitle_text.dart';
import 'package:location_project/widgets/textSF.dart';

class ProfileEditingPage extends StatefulWidget {
  final BuildContext contextToUse;

  const ProfileEditingPage(this.contextToUse);
  @override
  _ProfileEditingPageState createState() => _ProfileEditingPageState();
}

class _ProfileEditingPageState extends State<ProfileEditingPage> {
  static const int NbMaxUserPictures = 5;
  static const HPadding = 20.0;
  static const VPadding = 8.0;

  static const BioMaxCharacters = 500;
  static const NameMaxCharacters = 25;

  TextEditingController _textControllerBio;
  TextEditingController _textControllerName;

  double _age;

  @override
  void initState() {
    super.initState();
    _initTextFields();
    _initAge();
  }

  void _initTextFields() {
    _textControllerBio = TextEditingController(text: UserStore().user.bio);
    _textControllerName =
        TextEditingController(text: UserStore().user.firstName);
  }

  void _initAge() {
    _age = UserStore().user.age.toDouble();
  }

  _onDoneTap() {
    widget.contextToUse.read<EditProfileCubit>().didEditProfile(
          _textControllerBio.text,
          _textControllerName.text,
          _age.toInt(),
          DraggableImageCollection.StateImageURLs,
        );
    Navigator.pop(context);
  }

  Widget get _picturesWidget => DraggableImageCollection(
        [...UserStore().user.pictureURLs],
        NbMaxUserPictures,
      );

  Widget get _bioWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: HPadding, bottom: VPadding),
            child: AccountSubtitleText('📌 Bio'),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeUtils.getPrimaryDarkOrLightGrey(context),
              border: _textFieldBorder(),
            ),
            padding: EdgeInsets.only(
                left: HPadding, right: HPadding, top: 3, bottom: 3),
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              keyboardType: TextInputType.multiline,
              controller: _textControllerBio,
              maxLines: null,
              maxLength: BioMaxCharacters,
            ),
          ),
        ],
      );

  Widget get _nameWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: HPadding, bottom: VPadding),
            child: AccountSubtitleText('🖌 Name'),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeUtils.getPrimaryDarkOrLightGrey(context),
              border: _textFieldBorder(),
            ),
            padding: EdgeInsets.only(
                left: HPadding, right: HPadding, top: 3, bottom: 3),
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(NameMaxCharacters),
              ],
              decoration: InputDecoration(border: InputBorder.none),
              keyboardType: TextInputType.name,
              controller: _textControllerName,
              maxLines: 1,
            ),
          ),
        ],
      );

  Widget get _ageWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: HPadding, bottom: VPadding),
            child: AccountSubtitleText('🎂 Age'),
          ),
          Container(
            decoration: BoxDecoration(
              color: ThemeUtils.getPrimaryDarkOrLightGrey(context),
              border: _textFieldBorder(),
            ),
            padding: EdgeInsets.only(
                left: HPadding, right: HPadding, top: 6, bottom: 6),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 2 * HPadding,
                  child: CupertinoSlider(
                    value: _age,
                    activeColor: LogoOrangeColor,
                    min: Store.minAgeRange,
                    max: Store.maxAgeRange,
                    onChanged: (value) => setState(() => _age = value),
                  ),
                ),
                TextSF(
                  '${_age.round()}${_age.round() == Store.maxAgeRange ? "+" : ""} ',
                ),
              ],
            ),
          ),
        ],
      );

  Border _textFieldBorder() => Border(
        top: BorderSide(
            width: 0.6,
            color: ThemeUtils.getPrimaryDarkOrLightGreyAccent(context)),
        bottom: BorderSide(
            width: 0.6,
            color: ThemeUtils.getPrimaryDarkOrLightGreyAccent(context)),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                automaticallyImplyLeading: false,
                trailing: GestureDetector(
                  onTap: _onDoneTap,
                  child: Text('Done',
                      style: TextStyle(color: CupertinoColors.activeBlue)),
                ),
                largeTitle: Text(
                  'Edit profile',
                  style: TextStyle(
                      color: ThemeUtils.getBlackIfLightAndWhiteIfDark(context)),
                ),
              ),
            ];
          },
          body: ListView(
            children: [
              _picturesWidget,
              SizedBox(height: 10),
              _bioWidget,
              SizedBox(height: 20),
              _nameWidget,
              SizedBox(height: 20),
              _ageWidget,
            ],
          ),
        ),
      ),
    );
  }
}
