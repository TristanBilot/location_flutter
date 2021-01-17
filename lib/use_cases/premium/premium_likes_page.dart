import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/premium/widgets/premium_user_grid.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/widgets/textSF.dart';

class PremiumLikesPage extends StatefulWidget {
  @override
  _PremiumLikesPageState createState() => _PremiumLikesPageState();
}

class _PremiumLikesPageState extends State<PremiumLikesPage> {
  List<User> _users;

  Widget placeholder() => Container(
        child: Center(
          child: Column(
            children: [
              Spacer(),
              Icon(
                Icons.favorite,
                size: 60,
              ),
              SizedBox(height: 15),
              TextSF(
                'Nobody liked your profile yet.',
                fontSize: 18,
              ),
              Spacer(),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<CountersCubit, CountersState>(
      listener: (context, state) {
        if (state is NewLikesState) {
          setState(() {
            _users = state.likes;
          });
        }
      },
      child: _users != null && _users.isNotEmpty
          ? PremiumUserGrid(_users)
          : placeholder(),
    );
  }
}
