import 'package:flutter/material.dart';
import 'package:location_project/helpers/distance_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/use_cases/premium/premium_page.dart';
import 'package:location_project/widgets/cached_image.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';

class PremiumUserCard extends StatefulWidget {
  final User user;
  const PremiumUserCard(this.user);

  @override
  _PremiumUserCardState createState() => _PremiumUserCardState();
}

class _PremiumUserCardState extends State<PremiumUserCard> {
  static final double radius = 10.0;

  _onCardTap() {
    UserCard(PremiumPage.scaffoldKey.currentContext, widget.user).show();
  }

  Widget get _userInfoRow {
    String nameAge;
    String distance;
    if (widget.user.firstName == null || widget.user.age == null) {
      nameAge = '';
      distance = '';
    } else {
      nameAge = '${widget.user.firstName}, ${widget.user.age}';
      distance = '${DistanceAdapter().adapt(widget.user.distance)}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: TextSF(nameAge, fontSize: 19),
        ),
        TextSF(distance),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onCardTap,
      child: Container(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Container(
              child: SizedBox.expand(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: CachedImage(widget.user.mainPictureURL),
                ),
              ),
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  end: const Alignment(0.0, -1),
                  begin: const Alignment(0.0, 0.8),
                  colors: [
                    Colors.black45,
                    Colors.black12.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
              child: _userInfoRow,
            ),
          ],
        ),
      ),
    );
  }
}
