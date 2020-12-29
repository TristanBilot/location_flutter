import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/databases/messaging_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/premium/widgets/custom_rectangular_indicator.dart';
import 'package:location_project/use_cases/start_path/widgets/textsf_gradient.dart';
import 'package:location_project/use_cases/tab_pages/filters/chats_filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/filter.dart';
import 'package:location_project/use_cases/tab_pages/filters/request_filter.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chats/cubit/chat_cubit.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/chat_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/match_image.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:provider/provider.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage();

  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  static final double spaceBetweenTitleAndTabBar = 20.0;
  static final double spaceUnderTabBar = 10.0;
  static final double tabBarIndicatorRadius = 20.0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<ChatCubit>().fetchChats();
  }

  Widget _getIndicatorTextWidget(String text) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return TextSF(
      text,
      fontSize: 19,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white : Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: ThemeUtils.getPrimaryDarkOrLightGrey(context),
          bottom: PreferredSize(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      width: 0.4,
                      color:
                          ThemeUtils.getPrimaryDarkOrLightGreyAccent(context)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Who like you',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navLargeTitleTextStyle
                          .copyWith(
                              color: ThemeUtils.getBlackIfLightAndWhiteIfDark(
                                  context)),
                    ),
                  ),
                  SizedBox(height: spaceBetweenTitleAndTabBar),
                  TabBar(
                    indicator: CustomRectangularIndicator(
                      horizontalPadding: 10,
                      paintingStyle: PaintingStyle.stroke,
                      bottomLeftRadius: tabBarIndicatorRadius,
                      bottomRightRadius: tabBarIndicatorRadius,
                      topLeftRadius: tabBarIndicatorRadius,
                      topRightRadius: tabBarIndicatorRadius,
                      gradient: AppGradient,
                    ),
                    tabs: [
                      Tab(child: _getIndicatorTextWidget('23 likes')),
                      Tab(child: _getIndicatorTextWidget('127 views')),
                    ],
                  ),
                  SizedBox(height: spaceUnderTabBar),
                ],
              ),
            ),
            preferredSize: Size.fromHeight(
                80 + spaceBetweenTitleAndTabBar + spaceUnderTabBar),
          ),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.directions_car),
            Icon(Icons.directions_transit),
          ],
        ),
      ),
    );
  }
}
