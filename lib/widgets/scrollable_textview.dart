import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';

class ScrollableTextView extends StatelessWidget {
  final String placeholder;
  final Function(String value) onTextSubmitted;
  final bool withTrailingButton;
  final String trailingButtontext;
  final Function trailingButtonOnPressed;
  final TextEditingController controller;

  ScrollableTextView({
    this.placeholder = 'Send a nice message !',
    this.onTextSubmitted,
    this.withTrailingButton = false,
    this.trailingButtontext = 'Send',
    this.trailingButtonOnPressed,
    this.controller,
  }) {
    if (withTrailingButton && trailingButtonOnPressed == null)
      print(
          "+++ Error: trailingButtonOnPressed need a trailingButtonOnPressed callback.");
    if (trailingButtontext.length > 4)
      print(
          "+++ Warning: the trailingButtontext length is greater than 4 and will be too big, need to adapat.");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.7;
    double leftPadding = 20;
    double rightPadding = 50;
    double topPadding = 15;
    double bottomPadding = 15;

    return Stack(
      children: [
        Center(
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.fromLTRB(
                leftPadding, topPadding, rightPadding, bottomPadding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: TextField(
                  controller: controller,
                  onSubmitted: onTextSubmitted,
                  keyboardType: TextInputType.multiline,
                  maxLines: null, //grow automatically
                  decoration: InputDecoration.collapsed(
                    hintText: placeholder,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]..addAll(!withTrailingButton
          ? []
          : [
              Padding(
                padding: EdgeInsets.only(left: width - rightPadding - 10),
                child: FlatButton(
                  child: TextSF('Send'),
                  onPressed: trailingButtonOnPressed,
                ),
              )
            ]),
    );
  }
}
