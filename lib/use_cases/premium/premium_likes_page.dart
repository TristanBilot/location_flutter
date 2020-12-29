import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/premium/widgets/premium_user_card.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';

class PremiumLikesPage extends StatefulWidget {
  @override
  _PremiumLikesPageState createState() => _PremiumLikesPageState();
}

class _PremiumLikesPageState extends State<PremiumLikesPage> {
  static final double spacing = 15.0;
  List<User> _users;

  Widget _gridViewWidget() => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        padding: EdgeInsets.all(spacing),
        children: _users.map((user) => PremiumUserCard(user)).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountersCubit, CountersState>(builder: (context, state) {
      if (state is NewLikesState) {
        _users = state.likes;
        return _gridViewWidget();
      }
      return _users != null ? _gridViewWidget() : Container();
    });
  }
}
