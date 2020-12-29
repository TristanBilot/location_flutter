import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/premium/premium_likes_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:provider/provider.dart';

class PremiumPage extends StatefulWidget {
  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  MessagingDatabase _messagingDatabase;
  int _index;

  @override
  void initState() {
    super.initState();

    _index = 0;
    _messagingDatabase = MessagingDatabase();
    _fetch();
  }

  void _fetch() {
    context.read<ChatCubit>().fetchChats();
  }

  String _formatViewsIndicatorText() {
    int nbViews = _messagingDatabase.get(nbViews: true);
    if (nbViews == 0) return 'Views';
    return '$nbViews view${nbViews == 1 ? "" : "s"}';
  }

  String _formatLikesIndicatorText() {
    int nbLikes = _messagingDatabase.get(nbLikes: true);
    if (nbLikes == 0) return 'Likes';
    return '$nbLikes like${nbLikes == 1 ? "" : "s"}';
  }

  Widget _getIndicatorTextWidget(String text, int index) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    bool isSelected = index == _index;
    Color color;
    if (isSelected)
      color = isDark ? Colors.white : Colors.black;
    else
      color = isDark ? Colors.white60 : Colors.black38;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: TextSF(
        text,
        fontSize: 22,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                'Who like you',
                style: TextStyle(
                    color: ThemeUtils.getBlackIfLightAndWhiteIfDark(context)),
              ),
            )
          ];
        },
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
          },
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Flexible(
                      child: _getIndicatorTextWidget(
                        _formatLikesIndicatorText(),
                        0,
                      ),
                    ),
                    Spacer(),
                    _getIndicatorTextWidget(
                      _formatViewsIndicatorText(),
                      1,
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Divider(),
              Flexible(
                child: IndexedStack(
                  index: _index,
                  children: [
                    PremiumLikesPage(),
                    Text('page 2'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
