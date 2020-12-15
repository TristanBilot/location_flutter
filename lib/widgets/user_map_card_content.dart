import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/helpers/distance_adapter.dart';
import 'package:location_project/helpers/string_formatter.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/gradient_icon.dart';
import 'package:location_project/widgets/say_hello_button.dart';
import 'package:location_project/widgets/scrollable_textview.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_map_card.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../models/user.dart';

class UserMapCardContent extends StatefulWidget {
  final User user;
  final Function onSendTap;
  final Function onLikeTap;
  final Function onUnlikeTap;
  final Function onBlockTap;
  final TextEditingController messageEditingController;
  final RoundedLoadingButtonController blockButtonController;
  final Chat chatEntryIfExists;

  UserMapCardContent({
    @required this.user,
    @required this.onSendTap,
    @required this.onLikeTap,
    @required this.onUnlikeTap,
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
      height: UserMapCard.UserMapCardHeight,
      width: UserMapCard.UserMapCardHeight,
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
                          child: widget.user.distance == 0
                              ? SizedBox()
                              : TextSF(
                                  DistanceAdapter().adapt(widget.user.distance),
                                  fontWeight: FontWeight.w400,
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
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    // height: SayHelloButton.Height,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 40,
                                          child: FittedBox(
                                            child: FloatingActionButton(
                                              onPressed: widget.onLikeTap,
                                              backgroundColor: MediaQuery.of(
                                                              context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? DarkTheme.PrimaryDarkColor
                                                  : Theme.of(context)
                                                      .backgroundColor,
                                              child: GradientIcon(Icons.close,
                                                  32, GreyGradient),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        FloatingActionButton(
                                          onPressed: null, //  TODO
                                          backgroundColor:
                                              MediaQuery.of(context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? DarkTheme.PrimaryDarkColor
                                                  : Theme.of(context)
                                                      .backgroundColor,
                                          child: GradientIcon(
                                              Icons.notifications_active,
                                              30,
                                              GoldGradient),
                                        ),
                                        SizedBox(width: 20),
                                        Container(
                                          height: 40,
                                          child: FittedBox(
                                            child: FloatingActionButton(
                                              onPressed: widget.onLikeTap,
                                              backgroundColor: MediaQuery.of(
                                                              context)
                                                          .platformBrightness ==
                                                      Brightness.dark
                                                  ? DarkTheme.PrimaryDarkColor
                                                  : Theme.of(context)
                                                      .backgroundColor,
                                              child: GradientIcon(
                                                  Icons.favorite,
                                                  32,
                                                  AppGradient),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        // Spacer(),
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
