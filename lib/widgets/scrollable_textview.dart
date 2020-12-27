import 'package:flutter/material.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/widgets/textSF.dart';

class ScrollableTextView extends StatelessWidget {
  static const Height = 55.0;

  final String placeholder;
  final TextEditingController controller;
  final double width;

  final bool withSendButton;
  final String sendButtontext;
  final Function onSendPressed;
  final Widget customSendButton;

  ScrollableTextView({
    this.placeholder = 'Send a nice message !',
    @required this.controller,
    this.width,
    this.withSendButton = false,
    this.sendButtontext = 'Send',
    @required this.onSendPressed,
    this.customSendButton,
  }) {
    if (withSendButton && onSendPressed == null)
      Logger().e("onSendPressed need a onSendPressed callback.");
    if (sendButtontext.length > 4)
      Logger().w(
          "the sendButtontext length is greater than 4 and will be too big, need to adapat.");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.7;
    double leftPadding = 20;
    double rightPadding = 50;
    double topPadding = 15;
    double bottomPadding = 15;

    return Container(
      width: this.width ?? width,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: ThemeUtils.getBackgroundDarkOrLightGrey(context),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.fromLTRB(
                leftPadding, topPadding, rightPadding, bottomPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: ScrollableTextView.Height,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: null, //grow automatically
                  decoration: InputDecoration.collapsed(
                    hintText: placeholder,
                  ),
                ),
              ),
            ),
          ),
        ]..addAll(!withSendButton
            ? ([customSendButton] ?? [])
            : [
                Padding(
                  padding: EdgeInsets.only(left: width - rightPadding - 22),
                  child: FlatButton(
                    child: TextSF('Send'),
                    onPressed: onSendPressed,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                )
              ]),
      ),
    );
  }
}
