import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/models/gender.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/account/widgets/selectable_small_card_delegate.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/conf/extensions.dart';

class SelectableSmallCard extends StatefulWidget {
  final Gender gender;
  final SelectableSmallCardDelegate delegate;
  final bool isSelected;
  const SelectableSmallCard(this.gender, this.delegate, this.isSelected);

  @override
  _SelectableSmallCardState createState() =>
      _SelectableSmallCardState(isSelected);
}

class _SelectableSmallCardState extends State<SelectableSmallCard> {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RawMaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          shape: CircleBorder(),
          elevation: 1.0,
          onPressed: () {
            HapticFeedback.heavyImpact();
            setState(() => _isSelected = !_isSelected);
            widget.delegate.toggle(widget.gender, _isSelected);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: _getCardColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.fromLTRB(17, 6, 17, 6),
            child: TextSF(
              widget.gender.value,
              fontSize: 15,
              color: _getCardTextColor(),
            ),
          ),
        ),
      ],
    );
  }
}
