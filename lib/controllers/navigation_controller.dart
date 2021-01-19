import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/pages/home_page.dart';
import 'package:location_project/use_cases/premium/premium_nav_cubit/premium_nav_cubit.dart';
import 'package:location_project/use_cases/premium/premium_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';

class NavigationController {
  void navigateToMessagePage(User user, Chat chat, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessagePage(chat: chat, user: user)));
  }

  void navigateToPremiumLikePage() {
    PremiumPage.scaffoldKey.currentContext.read<PremiumNavCubit>().goTo(1);
    final BottomNavigationBar appBar =
        HomePage.appBarNavigationKey.currentWidget;
    appBar.onTap(4);
  }

  void navigateToPremiumViewPage() {
    PremiumPage.scaffoldKey.currentContext.read<PremiumNavCubit>().goTo(0);
    final BottomNavigationBar appBar =
        HomePage.appBarNavigationKey.currentWidget;
    appBar.onTap(4);
  }

  void navigateToMessagingPage() {
    final BottomNavigationBar appBar =
        HomePage.appBarNavigationKey.currentWidget;
    appBar.onTap(3);
  }
}
