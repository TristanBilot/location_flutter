import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/chat_tile.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../stores/extensions.dart';

class ChatsPage extends StatefulWidget {
  ChatsPage();

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  Stream<QuerySnapshot> _chatsStream;
  RefreshController _refreshController;

  @override
  void initState() {
    _fetchChatsStream();
    _refreshController = RefreshController(initialRefresh: false);

    super.initState();
  }

  Future<void> _fetchChatsStream() async {
    final userID = UserStore().user.id;
    final snapshots = await MessagingReposiory().getChats(userID);
    setState(() {
      _chatsStream = snapshots;
      print("we got the data + ${_chatsStream.toString()} for $userID");
    });
  }

  List<dynamic> _sortSnapshotsByMostRecent(List<dynamic> snapshots) {
    final mostRecent = ChatField.LastActivityTime.value;
    return snapshots
      ..sort((a, b) => (b.data()[mostRecent] as int)
          .compareTo((a.data()[mostRecent] as int)));
  }

  FirestoreChatEntry _objectToEntry(dynamic data) {
    return FirestoreChatEntry(
      List<String>.from(data[ChatField.UserIDs.value]),
      data[ChatField.ChatID.value] as String,
      data[ChatField.LastActivityTime.value] as int,
      data[ChatField.LastActivitySeen.value] as bool,
    );
  }

  void _onRefresh() async {
    if (mounted) setState(() => {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async => _refreshController.loadComplete();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 55.0,
            ),
          child: 
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null, //grow automatically
              decoration: InputDecoration.collapsed(
                hintText: 'placeholder',
              ),
            ),
          ),
          StreamBuilder(
            stream: _chatsStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // List a;
                // a.where((element) => false);
                // snapshot.data.where((a) => a.)
                final chats =
                    _sortSnapshotsByMostRecent(snapshot.data.documents);
                return SmartRefresher(
                  enablePullDown: true,
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  header: WaterDropMaterialHeader(), //WaterDropHeader
                  child: ListView.builder(
                      itemCount: chats.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ChatTile(
                            chat: _objectToEntry(chats[index].data()));
                      }),
                );
              }
              return Container();
            },
          ),),
        ],
      ),
    );
  }
}
