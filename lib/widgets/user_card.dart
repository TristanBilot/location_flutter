import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/controllers/messaging_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/blocking/cubit/blocking_cubit.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card_section.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/request_sender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_sender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/widgets/gradient_icon.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../models/user.dart';

class UserCard extends StatefulWidget {
  final BuildContext contextToUse;
  final User user;

  UserCard(
    this.contextToUse,
    this.user,
  );

  void show({bool addViewToStore = true}) {
    if (addViewToStore) UserStore().addView(user.id);
    showGeneralDialog(
        transitionBuilder: (context2, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: this,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 150),
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        barrierLabel: '',
        context: contextToUse,
        pageBuilder: (context, animation1, animation2) {});
  }

  static _UserCardState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserCardState>();

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  TextEditingController _messageEditingController;
  MessagingController _messagingController;
  RoundedLoadingButtonController _blockButtonController;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _messagingController = MessagingController();
    _blockButtonController = RoundedLoadingButtonController();
    super.initState();
  }

  /// Action when a user send directly a message to another person.
  /// The value of isEngaged is set at true so no need to accept.
  /// Creates a new chat and then insert a first message.
  Future<void> _sendMessage() async {
    if (_messageEditingController.text.isEmpty) return;
    // Create a new chat.
    User requester = UserStore().user;
    User requested = widget.user;
    final chatEntry = Chat.newChatEntry(
      requester.id,
      requested.id,
      requester.firstName,
      requested.firstName,
      true,
      false,
      true,
    );
    await MessagingReposiory().newChat(chatEntry.chatID, chatEntry);
    // Insert the first message.
    final message = _messageEditingController.text;
    MessageSender().send(message, chatEntry);
    setState(() => _messageEditingController.text = '');

    final data = (await MessagingReposiory().getChat(chatEntry.chatID)).data();
    final chat = Chat.fromFirestoreObject(data);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: chat,
          user: widget.user,
        ),
      ),
    );
  }

  _onLikeTap() async {
    User liked = widget.user;
    // en attendant car ça ne marche pas (erreur provider)
    await UserStore().addLike(liked.id);
    RequestSender().sendRequestTo(liked);
    // context.read<SwipeButtonsCubit>().like(liked);
  }

  _onUnlikeTap() {
    User unliked = widget.user;
    context.read<SwipeButtonsCubit>().unlike(unliked);
  }

  /// Action when the user blocks another user on the map.
  Future<void> _blockUser(BuildContext context) async {
    User blockedUser = widget.user;
    UserStore().addBlockedUser(blockedUser.id).then((_) async {
      _blockButtonController.success();
      HapticFeedback.mediumImpact();
      context.read<BlockingCubit>().emitNewUserWhoBlockedMe();
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pop();
    });
  }

  Future<List<DocumentSnapshot>> _fetchChatInfo(String otherUserID) async {
    Stopwatch stopwatch = new Stopwatch()..start();
    String id = UserStore().user.id;
    String chatID = MessagingReposiory.getChatID(id, otherUserID);
    final chat = MessagingReposiory().getChat(chatID);
    int chatInfoFetchingTime = stopwatch.elapsed.inMilliseconds;
    Logger().v('chat info fetched in ${chatInfoFetchingTime}ms');
    return Future.wait([chat]);
  }

  _unlike(User user, int index) {
    widget.contextToUse.read<SwipeButtonsCubit>().unlike(user);
    Navigator.of(context).pop();
  }

  _like(User user, int index) {
    widget.contextToUse
        .read<SwipeButtonsCubit>()
        .like(user, widget.contextToUse);
    Navigator.of(context).pop();
  }

  _chat(User user, Chat chat) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: chat,
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // To dismiss keyboard.
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 5),
          child: Container(
            child: FutureBuilder(
              future: _fetchChatInfo(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data[0].data();
                  final chatEntryIfExists =
                      data == null ? null : Chat.fromFirestoreObject(data);

                  return SwipeCardSection(
                    0,
                    UniqueKey(),
                    widget.user,
                    _like,
                    _unlike,
                    useSectionOutsideOfSwipeCard: true,
                    actionButtonsWidget: chatEntryIfExists != null
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 15),
                            child: FloatingActionButton(
                              onPressed: () =>
                                  _chat(widget.user, chatEntryIfExists),
                              backgroundColor:
                                  ThemeUtils.getBackgroundDarkOrBackgroundLight(
                                      context),
                              child: GradientIcon(
                                Icons.chat,
                                30,
                                GoldGradient,
                              ),
                            ),
                          )
                        : null,
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
