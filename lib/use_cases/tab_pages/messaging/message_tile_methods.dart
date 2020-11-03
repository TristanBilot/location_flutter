import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/widgets/textSF.dart';

class MessageTileMethods {
  final FirestoreMessageEntry message;
  final int diffWithPrevMsgTime;

  static const ValueForFirstMessage = -1;
  static const IntervalToDisplayTime = 1; // in hour
  static const MessageRadius = 23.0;

  MessageTileMethods(
    this.message,
    this.diffWithPrevMsgTime,
  );

  Widget getTimeText(BuildContext context, bool sentByMe) {
    DateTime diff = DateTime.fromMicrosecondsSinceEpoch(diffWithPrevMsgTime);
    int diffInHours = diff.hour;

    if (diffWithPrevMsgTime == ValueForFirstMessage ||
        diffInHours > IntervalToDisplayTime) {
      DateTime time = DateTime.fromMicrosecondsSinceEpoch(message.time);
      int diffBetweenMsgAndNow =
          DateTime.now().subtract(Duration(microseconds: message.time)).day - 1;

      String day = time.day.toString().padLeft(2, '0');
      String month = time.month.toString().padLeft(2, '0');
      String dayStr;

      if (diffBetweenMsgAndNow == 0)
        dayStr = 'Today ';
      else if (diffBetweenMsgAndNow == 1)
        dayStr = 'Yesterday ';
      else
        dayStr = '$day/$month - '; // inverse order in English

      String hour = time.hour.toString().padLeft(2, '0');
      String min = time.minute.toString().padLeft(2, '0');
      String hourMinStr = '$hour:$min';

      final fontSize = 12.0;
      TextSpan displayedTime = TextSpan(
        style: TextSF.TextSFStyle.copyWith(
            color: Theme.of(context).textTheme.headline6.color),
        children: [
          TextSpan(
            text: dayStr,
            style: TextSF.TextSFStyle.copyWith(fontSize: fontSize),
          ),
          TextSpan(
              text: hourMinStr,
              style: TextSF.TextSFStyle.copyWith(
                  fontWeight: FontWeight.w400, fontSize: fontSize)),
        ],
      );
      RenderParagraph renderParagraph = RenderParagraph(
        displayedTime,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      // get the width of the text widget.
      double textLen = renderParagraph.getMinIntrinsicWidth(14).ceilToDouble();
      final centeringPadding =
          MediaQuery.of(context).size.width / 2 - textLen / 2 - 20;
      return Container(
        padding: sentByMe
            ? EdgeInsets.fromLTRB(0, 20, centeringPadding, 20)
            : EdgeInsets.fromLTRB(centeringPadding, 20, 0, 20),
        child: RichText(text: displayedTime),
      );
    }
    return SizedBox();
  }

  List<Color> getMessageBackgroundColor(bool sentByMe, BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    Color receivedDark = Color(0xFF616165);
    Color receivedLight = Color(0xFFceced4);
    final List<Color> received =
        isDark ? [receivedDark, receivedDark] : [receivedLight, receivedLight];
    return sentByMe ? [Color(0xff007EF4), Color(0xff2A75BC)] : received;
  }

  Color getMessageTextColor(bool sentByMe, BuildContext context) {
    if (sentByMe) return Colors.white;
    return Theme.of(context).textTheme.headline6.color;
  }

  BorderRadiusGeometry radiusSentByMeMsg = BorderRadius.only(
      topLeft: Radius.circular(MessageRadius),
      topRight: Radius.circular(MessageRadius),
      bottomLeft: Radius.circular(MessageRadius));

  BorderRadiusGeometry radiusReceivedMsg = BorderRadius.only(
      topLeft: Radius.circular(MessageRadius),
      topRight: Radius.circular(MessageRadius),
      bottomRight: Radius.circular(MessageRadius));
}
