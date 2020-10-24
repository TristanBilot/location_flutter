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
  TextEditingController _messageEditingController;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _fetchChatsStream();

    super.initState();
  }

  /// Fetch the stream of chats and setState() to consume the
  /// stream builder.
  Future<void> _fetchChatsStream() async {
    final userID = UserStore().user.id;
    final snapshots = await MessagingReposiory().getChats(userID);
    setState(() {
      _chatsStream = snapshots;
      print("we got the data + ${_chatsStream.toString()} for $userID");
    });
  }

  /// Sort the snapshots in ascending last message order.
  List<dynamic> _sortSnapshotsByMostRecent(List<dynamic> snapshots) {
    final mostRecent = ChatField.LastActivityTime.value;
    return snapshots
      ..sort((a, b) => (b.data()[mostRecent] as int)
          .compareTo((a.data()[mostRecent] as int)));
  }

  /// Return the same list of snapshots with only the chats with
  /// participants which the name match the string `pattern`.
  /// This function is used for the search feature.
  /// Return the same list of snapshots unchanged if `pattern` is empty.
  List<dynamic> _filterStreamByName(List<dynamic> snapshots, String pattern) {
    if (pattern.length == 0) return snapshots;
    return snapshots.where((snapshot) {
      final chat = FirestoreChatEntry.fromFirestoreObject(snapshot.data());
      final otherParticipantName = (chat.userNames
            ..removeWhere((userName) => userName == UserStore().user.firstName))
          .first;
      return otherParticipantName.toLowerCase().contains(pattern.toLowerCase());
    }).toList();
  }

  void _onRefresh() async {
    if (mounted) setState(() => {});
    _refreshController.refreshCompleted();
  }

  void _onLoading() async => _refreshController.loadComplete();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoTextField(
              padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
              controller: _messageEditingController,
              onChanged: (text) => setState(() => {}),
              style:
                  TextStyle(color: Theme.of(context).textTheme.headline6.color),
              // clearButtonMode: OverlayVisibilityMode.editing,
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: Colors.grey[500], width: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              placeholder: 'Search someone',
            ),
          ),
          // Text('hello'),
          Flexible(
            child: StreamBuilder(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sortedChats =
                      _sortSnapshotsByMostRecent(snapshot.data.documents);
                  final chats = _filterStreamByName(
                      sortedChats, _messageEditingController.text);
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
                              chat: FirestoreChatEntry.fromFirestoreObject(
                                  chats[index].data()));
                        }),
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
