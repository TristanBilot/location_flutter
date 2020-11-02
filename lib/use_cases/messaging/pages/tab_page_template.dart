import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/messaging/pages/builders/tab_page_stream_builder.dart';
import 'package:location_project/use_cases/messaging/pages/tab_page_type.dart';
import 'package:location_project/widgets/basic_cupertino_text_field.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabPageTemplate extends StatefulWidget {
  final TabPageStreamBuilder builder;
  final TabPageType type;

  TabPageTemplate(this.builder, this.type);

  @override
  _TabPageTemplateState createState() => _TabPageTemplateState();
}

class _TabPageTemplateState extends State<TabPageTemplate> {
  Stream<QuerySnapshot> _stream;
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

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future<void> _fetchChatsStream() async {
    final userID = UserStore().user.id;
    switch (widget.type) {
      case TabPageType.Chats:
        _stream = await MessagingReposiory().getChats(userID);
        break;
      case TabPageType.Requests:
        _stream = await MessagingReposiory().getChats(userID);
        break;
      case TabPageType.Views:
        _stream =
            await MessagingReposiory().getChats(userID); // TODO A MODIFIER
        break;
    }
    setStateIfMounted(() => print("++++ ${_stream.toString()} fetched."));
  }

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

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
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return widget.builder.build(
                      context,
                      widget.type,
                      snapshot,
                      _shouldRefreshCache,
                      _messageEditingController,
                      _refreshController,
                      _onRefresh);
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
