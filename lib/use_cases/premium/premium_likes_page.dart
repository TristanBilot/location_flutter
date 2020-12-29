import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/use_cases/premium/widgets/premium_user_card.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';

class PremiumLikesPage extends StatefulWidget {
  @override
  _PremiumLikesPageState createState() => _PremiumLikesPageState();
}

class _PremiumLikesPageState extends State<PremiumLikesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountersCubit, CountersState>(builder: (context, state) {
      if (state is NewLikesState) {
        final likes = state.likes;
        return GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(10),
          children: likes.map((user) => PremiumUserCard(user)).toList(),
        );
      }
      return Container();
    });
  }
}
