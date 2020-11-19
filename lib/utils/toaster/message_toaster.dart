import 'package:flutter/material.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/utils/toaster/toaster_library.dart';
import 'package:location_project/widgets/textSF.dart';

class MessageToast extends StatelessWidget {
  final FToast fToast = FToast();
  final BuildContext context;
  final String from;
  final String message;

  MessageToast(this.context, this.from, this.message) {
    fToast.init(context);
  }

  show() {
    fToast.showToast(
        child: this,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 0,
            left: 0,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: DarkTheme.BackgroundDarkColor.withOpacity(0.9),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 50, 8, 10),
        child: Row(
          children: [
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSF(this.from, color: Colors.white, fontSize: 15),
                SizedBox(height: 5),
                TextSF(this.message,
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
