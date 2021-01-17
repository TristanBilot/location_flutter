import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/premium/widgets/premium_user_card.dart';

class PremiumUserGrid extends StatefulWidget {
  final List<User> users;
  const PremiumUserGrid(this.users);

  @override
  _PremiumUserGridState createState() => _PremiumUserGridState();
}

class _PremiumUserGridState extends State<PremiumUserGrid> {
  static final double spacing = 15.0;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      padding: EdgeInsets.all(spacing),
      children: widget.users
          .map((user) => PremiumUserCard(user, key: UniqueKey()))
          .toList(),
    );
  }
}
