import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/premium/premium_likes_page.dart';
import 'package:location_project/use_cases/premium/premium_nav_cubit/premium_nav_cubit.dart';
import 'package:location_project/use_cases/premium/premium_views_page.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/widgets/textSF.dart';

class PremiumPage extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  final initialIndex;

  PremiumPage({this.initialIndex = 0});

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  MessagingDatabase _messagingDatabase;
  int _index;
  int _nbLikes;
  int _nbViews;

  @override
  void initState() {
    super.initState();

    _index = widget.initialIndex;
    _messagingDatabase = MessagingDatabase();
    _initCounters();
  }

  void _initCounters() {
    _nbLikes = _messagingDatabase.get(nbLikes: true);
    _nbViews = _messagingDatabase.get(nbViews: true);
  }

  String _formatViewsIndicatorText() {
    if (_nbViews == 0) return 'Views';
    return '$_nbViews view${_nbViews == 1 ? "" : "s"}';
  }

  String _formatLikesIndicatorText() {
    if (_nbLikes == 0) return 'Likes';
    return '$_nbLikes like${_nbLikes == 1 ? "" : "s"}';
  }

  void _onSwitchPage(int index) {
    setState(() => _index = index);
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
      onTap: () => _onSwitchPage(index),
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
    return BlocListener<PremiumNavCubit, PremiumNavState>(
      listener: (context, state) {
        if (state is PremiumNavCubitIndexSwitched) {
          _onSwitchPage(state.index);
        }
      },
      child: CupertinoPageScaffold(
        key: PremiumPage.scaffoldKey,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              CupertinoSliverNavigationBar(
                heroTag: 'tag4',
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
                  child: BlocListener<CountersCubit, CountersState>(
                    listener: (context, state) {
                      if (state is CounterStoreState)
                        setState(() {
                          _nbLikes = state.counter.nbLikes;
                          _nbViews = state.counter.nbViews;
                        });
                    },
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
                ),
                Divider(),
                Flexible(
                  child: IndexedStack(
                    index: _index,
                    children: [
                      Builder(builder: (context) => PremiumLikesPage()),
                      Builder(builder: (context) => PremiumViewsPage()),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
