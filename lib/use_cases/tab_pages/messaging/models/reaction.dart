import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/conf/extensions.dart';

enum Reaction {
  NoReaction,
  Heart,
  Laugh,
  Sad,
  Yes,
}

extension ReactionExtension on Reaction {
  static Reaction fromString(String reaction) {
    if (reaction == Reaction.NoReaction.value) return Reaction.NoReaction;
    if (reaction == Reaction.Heart.value) return Reaction.Heart;
    if (reaction == Reaction.Laugh.value) return Reaction.Laugh;
    if (reaction == Reaction.Sad.value) return Reaction.Sad;
    if (reaction == Reaction.Yes.value) return Reaction.Yes;
    return Reaction.NoReaction;
  }

  String get emoji {
    switch (this) {
      case Reaction.NoReaction:
        return '';
      case Reaction.Heart:
        return '❤';
      case Reaction.Laugh:
        return '😂';
      case Reaction.Sad:
        return '😔';
      case Reaction.Yes:
        return '👍';
      default:
        return '';
    }
  }

  Widget emojiWidget(Chat chat, Message message, BuildContext context) {
    return GestureDetector(
      onTap: () => _onReactionPress(chat, message, context),
      child: Container(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            this.emoji,
            style: TextStyle(fontSize: 22),
          )),
    );
  }

  _onReactionPress(Chat chat, Message message, BuildContext context) {
    MessagingReposiory().updateMessageReaction(chat, message, this);
    Navigator.of(context).pop();
  }
}
