import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/string_formatter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/say_hello_button.dart';
import 'package:location_project/widgets/scrollable_textview.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../models/user.dart';

class UserMapCardContent extends StatefulWidget {
  final User user;
  final Function onSendTap;
  final Function onSayHiTap;
  final Function onBlockTap;
  final TextEditingController messageEditingController;
  final RoundedLoadingButtonController blockButtonController;
  final FirestoreChatEntry chatEntryIfExists;

  UserMapCardContent({
    @required this.user,
    @required this.onSendTap,
    @required this.onSayHiTap,
    @required this.onBlockTap,
    @required this.messageEditingController,
    @required this.blockButtonController,
    @required this.chatEntryIfExists,
  });

  @override
  _UserMapCardContentState createState() => _UserMapCardContentState();
}

class _UserMapCardContentState extends State<UserMapCardContent> {
  static const InternalPadding = 10.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const PictureSize = 130.0;

    return Container(
      height: 400,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Material(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
          child: SafeArea(
            top: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    InternalPadding, InternalPadding, InternalPadding, 0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: CachedCircleUserImage(
                            widget.user.pictureURL,
                            size: PictureSize,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: TextSF(
                            StringFormatter().getNameAgeLabel(
                                widget.user.firstName, widget.user.age),
                            fontSize: TextSF.FontSize + 4,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                          child: TextSF(
                            widget.user.distance == 0
                                ? ''
                                : '${widget.user.distance} meters',
                          ),
                        ),
                        Spacer(),
                        widget.chatEntryIfExists != null
                            ? Container(
                                width: MediaQuery.of(context).size.width,
                                child: BasicButton(
                                  'Chat with ${widget.user.firstName}',
                                  fontsSize: 18,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MessagePage(
                                          chat: widget.chatEntryIfExists,
                                          user: widget.user,
                                        ),
                                      ),
                                    );
                                  },
                                ))
                            : Column(
                                children: [
                                  Container(
                                    height: ScrollableTextView.Height,
                                    child: Center(
                                      child: ScrollableTextView(
                                        controller:
                                            widget.messageEditingController,
                                        withSendButton: true,
                                        onSendPressed: widget.onSendTap,
                                      ),
                                    ),
                                  ),
                                  // Spacer(),
                                  Container(
                                    height: SayHelloButton.Height,
                                    child: SayHelloButton(
                                      onPressed: widget.onSayHiTap,
                                      userName: widget.user.firstName,
                                    ),
                                  ),
                                ],
                              ),
                        Spacer(),
                      ],
                    ),
                    Positioned(
                      left: InternalPadding,
                      top: InternalPadding,
                      child: RoundedLoadingButton(
                        controller: widget.blockButtonController,
                        onPressed: widget.onBlockTap,
                        child: TextSF(
                          'Block',
                          fontSize: 12,
                        ),
                        height: 30,
                        width: 60,
                        color: Theme.of(context).backgroundColor,
                        valueColor: Theme.of(context).textTheme.headline6.color,
                      ),
                    ),
                    Positioned(
                        right: InternalPadding,
                        top: InternalPadding,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
