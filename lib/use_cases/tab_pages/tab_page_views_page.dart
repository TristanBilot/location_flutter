import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_refresher.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_view_tile.dart';
import '../../stores/extensions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabPageViewsPage extends StatefulWidget {
  @override
  _TabPageViewsPageState createState() => _TabPageViewsPageState();
}

class _TabPageViewsPageState extends State<TabPageViewsPage> {
  Stream<QuerySnapshot> _stream;
  RefreshController _refreshController;
  bool _shouldRefreshCache;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    _shouldRefreshCache = false;
    _fetchChatsStream();

    super.initState();
  }

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  Future<void> _fetchChatsStream() async {
    final id = UserStore().user.id;
    _stream = await UserRepository().getStream(id, UserField.ViewedUserIDs);
    setStateIfMounted(() => print("++++ ${_stream.toString()} fetched."));
  }

  Function(List<dynamic>) get filter => (snapshots) => snapshots
      .where(
          (chat) => chat.data()[ChatField.IsChatEngaged.value] as bool == false)
      .toList()
        ..sort((a, b) {
          bool isUserRequested =
              (b.data()[ChatField.RequestedID.value] as String) ==
                  UserStore().user.id;
          return isUserRequested ? 1 : -1;
        });

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  List<String> _fromSnapshotToIDsList(AsyncSnapshot snapshot) {
    if (snapshot.data.documents.isEmpty) return [];
    return List<String>.from(
        snapshot.data.documents.map((doc) => doc.id).toList());
  }

  Widget get placeholder =>
      TabPagePlaceholer('Nobody viewed your profile yet.');
  TabPageType get type => TabPageType.Views;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: _stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final viewersIDs = _fromSnapshotToIDsList(snapshot);
                  return TabPageRefresher(
                    _onRefresh,
                    _refreshController,
                    viewersIDs.length != 0
                        ? ListView.builder(
                            itemCount: viewersIDs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return TabPageViewTile(
                                viewersIDs[index],
                                _shouldRefreshCache,
                              );
                            })
                        : placeholder,
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
