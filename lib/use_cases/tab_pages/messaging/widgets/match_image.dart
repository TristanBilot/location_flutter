import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/widgets/textSF.dart';

class MatchImage extends StatefulWidget {
  static const double ImageSize = 60.0;

  final String id;
  final Chat chat;
  const MatchImage(this.id, this.chat);

  @override
  _MatchImageState createState() => _MatchImageState();
}

class _MatchImageState extends State<MatchImage> {
  Future<List<dynamic>> _fetch() async {
    Future<Stream<UserMandatoryInfo>> futureUser() async =>
        UserRepository().fetchUserInfoStream(widget.id);

    final userInfoStream = futureUser();
    final userPictures = UserIconInfoFetcher().fetch(widget.id);
    return Future.wait([userInfoStream, userPictures]);
  }

  _onTap(BuildContext thisContext, User user) {
    Navigator.push(
      thisContext,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: widget.chat,
          user: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      child: FutureBuilder(
          future: _fetch(),
          builder: (futureContext, snapshot) {
            if (snapshot.hasData) {
              final userInfoStream =
                  snapshot.data[0] as Stream<UserMandatoryInfo>;
              final userPictures = snapshot.data[1] as UserIconInfo;

              return StreamBuilder(
                  stream: userInfoStream,
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasData) {
                      final userInfo = userSnapshot.data as UserMandatoryInfo;
                      final user = User.public()
                        ..build(infos: userInfo)
                        ..build(pictures: userPictures);
                      return GestureDetector(
                        onTap: () => _onTap(context, user),
                        child: Column(
                          children: [
                            CachedCircleUserImageWithActiveStatus(
                              pictureURL: user.mainPictureURL,
                              isActive: user.settings.connected,
                              statusSize: 12,
                              statusAlignment: Alignment.bottomRight,
                              size: MatchImage.ImageSize,
                              borderColor: Colors.transparent,
                            ),
                            SizedBox(height: 5),
                            TextSF(
                              user.firstName,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }
                    return Container();
                  });
            }
            return Container();
          }),
    );
  }
}
