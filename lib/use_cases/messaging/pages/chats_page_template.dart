import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/chat_tile.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/messaging/pages/chats_page_type.dart';
import 'package:location_project/widgets/basic_cupertino_text_field.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../stores/extensions.dart';

class ChatsPageTemplate extends StatefulWidget {
  final Function(List<dynamic>) filter;
  final ChatsPageType chatsType;

  ChatsPageTemplate(this.filter, this.chatsType);

  @override
  _ChatsPageTemplateState createState() => _ChatsPageTemplateState();
}

class _ChatsPageTemplateState extends State<ChatsPageTemplate> {
  Stream<QuerySnapshot> _chatsStream;
  RefreshController _refreshController;
  TextEditingController _messageEditingController;

  // Only true when the refresh controller is used when
  // swipe is handle in order to refresh all the chats cache.
  bool _shouldRefreshCache;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _refreshController = RefreshController(initialRefresh: false);
    _shouldRefreshCache = false;
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
    _shouldRefreshCache = true;
    if (mounted) setState(() => {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  Widget get _noChatsPlaceholder => Center(
          child: TextSF(
        'No discussions yet.',
        fontSize: 18,
        color: Colors.grey,
      ));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BasicCupertinoTextField(
              controller: _messageEditingController,
              onChanged: (text) => setState(() => {}),
              maxLines: 1,
              placeholder: 'Search someone',
              clearButtonMode: OverlayVisibilityMode.editing,
              autoCorrect: false,
              enableSuggestions: false,
              leadingWidget: Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Icon(Icons.search),
              ),
            ),
          ),
          Flexible(
            child: StreamBuilder(
              stream: _chatsStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sortedChats =
                      _sortSnapshotsByMostRecent(snapshot.data.documents);
                  final filteredChats = _filterStreamByName(
                      sortedChats, _messageEditingController.text);
                  final chats = widget.filter(filteredChats);
                  return SmartRefresher(
                    enablePullDown: true,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    header: WaterDropMaterialHeader(), //WaterDropHeader
                    child: chats.length != 0
                        ? ListView.builder(
                            itemCount: chats.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ChatTile(
                                chat: FirestoreChatEntry.fromFirestoreObject(
                                    chats[index].data()),
                                shouldRefreshCache: _shouldRefreshCache,
                                chatsType: widget.chatsType,
                              );
                            })
                        : _noChatsPlaceholder,
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
