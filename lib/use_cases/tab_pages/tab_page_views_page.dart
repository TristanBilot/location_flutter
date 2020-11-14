import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/use_cases/tab_pages/messaging/views/cubit/view_cubit.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_refresher.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_view_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabPageViewsPage extends StatefulWidget {
  @override
  _TabPageViewsPageState createState() => _TabPageViewsPageState();
}

class _TabPageViewsPageState extends State<TabPageViewsPage> {
  RefreshController _refreshController;
  bool _shouldRefreshCache;

  @override
  void initState() {
    _refreshController = RefreshController(initialRefresh: false);
    _shouldRefreshCache = false;
    _fetch();

    super.initState();
  }

  void _fetch() {
    context.read<ViewCubit>().fetchViews();
  }

  setStateIfMounted(Function f) {
    if (mounted) setState(f);
  }

  void _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    _refreshController.refreshCompleted();
    // need to be improved later, set to false after stream building, not build().
    Future.delayed(Duration(seconds: 1), () => _shouldRefreshCache = false);
  }

  Widget get placeholder => BasicPlaceholder('Nobody viewed your profile yet.');

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
            child: BlocBuilder<ViewCubit, ViewState>(
              builder: (context, state) {
                if (state is ViewFetchedState) {
                  final viewersIDs = state.viewerIDs;
                  MessagingDatabase().putNbViews(viewersIDs.length);

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
                return Center(child: CupertinoActivityIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
