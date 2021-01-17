import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/premium/widgets/premium_user_grid.dart';
import 'package:location_project/use_cases/tab_pages/counters/cubit/counters_cubit.dart';
import 'package:location_project/widgets/textSF.dart';

class PremiumViewsPage extends StatefulWidget {
  @override
  _PremiumViewsPageState createState() => _PremiumViewsPageState();
}

class _PremiumViewsPageState extends State<PremiumViewsPage> {
  List<User> _users;

  Widget placeholder() => Container(
        child: Center(
          child: Column(
            children: [
              Spacer(),
              Icon(
                Icons.remove_red_eye_rounded,
                size: 60,
              ),
              SizedBox(height: 15),
              TextSF(
                'Nobody viewed your profile yet.',
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
        if (state is NewViewsState) {
          setState(() {
            _users = state.views;
          });
        }
      },
      child: _users != null && _users.isNotEmpty
          ? PremiumUserGrid(_users)
          : placeholder(),
    );
  }
}
