import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card_delegate.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/conf/extensions.dart';

class GenderSmallCard extends StatefulWidget {
  final Gender gender;
  final GenderSmallCardDelegate delegate;
  final bool isSelected;
  const GenderSmallCard(this.gender, this.delegate, this.isSelected);

  @override
  _SelectableSmallCardState createState() =>
      _SelectableSmallCardState(isSelected);
}

class _SelectableSmallCardState extends State<GenderSmallCard> {
  bool _isSelected = false;

  _SelectableSmallCardState(this._isSelected);

  LinearGradient _getCardColor() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (_isSelected)
      return AppGradient;
    else {
      if (isDark)
        return LinearGradient(colors: [
          DarkTheme.BackgroundDarkColor,
          DarkTheme.BackgroundDarkColor
        ]);
      return LinearGradient(colors: [Color(0xFFF1F1F1), Color(0xFFF1F1F1)]);
    }
  }

  Color _getCardTextColor() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    if (_isSelected || isDark) return Colors.white;
    return Colors.black45;
  }

  String _getGenderIcon(Gender gender) {
    switch (gender) {
      case Gender.Female:
        return '💁‍♀️';
      case Gender.Male:
        return '🙋‍♂️';
      case Gender.Other:
        return '🤷‍';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        setState(() => _isSelected = !_isSelected);
        widget.delegate.toggle(widget.gender, _isSelected);
      },
      child: Column(
        children: [
          Text(
            _getGenderIcon(widget.gender),
            style: TextStyle(fontSize: 50),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(17, 6, 17, 6),
            decoration: BoxDecoration(
              gradient: _getCardColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextSF(
              widget.gender.value,
              fontSize: 18,
              color: _getCardTextColor(),
            ),
          ),
        ],
      ),
    );
  }
}
