import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SayHelloButton extends StatefulWidget {
  final String text;
  final String userName;
  final Future<void> Function() onPressed;
  final int animationTime;

  const SayHelloButton({
    @required this.onPressed,
    @required this.userName,
    this.text = 'Say hi 👋',
    this.animationTime = 300,
  });

  @override
  _SayHelloButtonState createState() => _SayHelloButtonState();
}

class _SayHelloButtonState extends State<SayHelloButton> {
  final _btnController = RoundedLoadingButtonController();
  bool _helloAlreadySent = false;

  void setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future<void> onSayHelloPressed() async {
    await widget.onPressed();
    setStateIfMounted(() {
      _btnController.success();
      Timer(Duration(milliseconds: 1500),
          () => setStateIfMounted(() => _helloAlreadySent = true));
    });
  }

  String get getHelloAlreadySentText {
    if (widget.userName == null)
      return 'A notification has been sent!';
    else
      return 'A notification has been sent to ${widget.userName}!';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      AnimatedOpacity(
        opacity: _helloAlreadySent ? 1 : 0,
        duration: Duration(milliseconds: widget.animationTime),
        child: TextSF(
          getHelloAlreadySentText,
          align: TextAlign.center,
        ),
      ),
      AnimatedOpacity(
        opacity: _helloAlreadySent ? 0 : 1,
        duration: Duration(milliseconds: widget.animationTime),
        child: RoundedLoadingButton(
          child: TextSF(
            widget.text,
            color: Colors.white,
            fontSize: TextSF.FontSize + 2,
          ),
          controller: _btnController,
          height: 37,
          width: 110,
          onPressed: onSayHelloPressed,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ]);
  }
}
