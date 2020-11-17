import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/stores/messaging_database.dart';
import 'package:location_project/use_cases/tab_pages/messaging/views/cubit/view_cubit.dart';
import 'package:location_project/widgets/basic_placeholder.dart';
import 'package:location_project/use_cases/tab_pages/widgets/tab_page_view_tile.dart';

class TabPageViewsPage extends StatefulWidget {
  @override
  _TabPageViewsPageState createState() => _TabPageViewsPageState();
}

class _TabPageViewsPageState extends State<TabPageViewsPage> {
  bool _shouldRefreshCache;

  @override
  void initState() {
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

  Future<void> _onRefresh() async {
    _shouldRefreshCache = true;
    setStateIfMounted(() {});
    HapticFeedback.mediumImpact();
    // need to be improved later, set to false after stream building, not build().
    await Future.delayed(Duration(milliseconds: 800), () {
      _shouldRefreshCache = false;
      HapticFeedback.lightImpact();
    });
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
          SizedBox(height: 3),
          Flexible(
            child: BlocBuilder<ViewCubit, ViewState>(
              builder: (context, state) {
                if (state is ViewFetchedState) {
                  final views = state.viewerIDs;
                  MessagingDatabase().put(nbViews: views.length);

                  return views.length != 0
                      ? CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                              CupertinoSliverRefreshControl(
                                  onRefresh: _onRefresh),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return TabPageViewTile(
                                        views[index], _shouldRefreshCache);
                                  },
                                  childCount: views.length,
                                ),
                              )
                            ])
                      : placeholder;
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
