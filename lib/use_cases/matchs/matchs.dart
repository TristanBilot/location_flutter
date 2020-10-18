import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:location_project/stores/map_store.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

class Matchs extends StatefulWidget {
  @override
  MatchsState createState() => MatchsState();
}

class MatchsState extends State<Matchs> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: MapStore()
            .unlikedUsers
            .map((user) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          user.firstName,
                        ),
                        subtitle: Text('At ${user.distance}m'),
                        trailing: Icon(Icons.chevron_right),
                        leading: CachedCircleUserImage(
                          user.pictureURL,
                          size: 55,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
