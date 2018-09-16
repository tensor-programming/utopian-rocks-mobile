import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';
import 'package:intl/intl.dart';

import 'package:rxdart/rxdart.dart';

import 'package:utopian_rocks/components/list_page.dart';
import 'package:utopian_rocks/components/drawer.dart';

import 'package:utopian_rocks/model/repository.dart';

import 'package:utopian_rocks/providers/contribution_provider.dart';
import 'package:utopian_rocks/blocs/contribution_bloc.dart';
import 'package:utopian_rocks/blocs/information_bloc.dart';
import 'package:utopian_rocks/providers/information_provider.dart';
import 'package:utopian_rocks/model/htmlParser.dart';
import 'package:utopian_rocks/model/githubApi.dart';
import 'package:utopian_rocks/utils/utils.dart';

void main() => runApp(MyApp());

// Root of the widget tree.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // root widget is the [ContributionProvider] so that the BLoC is available anywhere.
    return InformationProvider(
      informationBloc: InformationBloc(
        PackageInfo.fromPlatform(),
        GithubApi(),
      ),
      child: ContributionProvider(
        // Instantiate the API and the BLoC for the entire application.
        contributionBloc: ContributionBloc(
          Api(),
          ParseWebsite(),
        ),
        child: RootApp(),
      ),
    );
  }
}

class RootApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final informationBloc = InformationProvider.of(context);
    final contributionBloc = ContributionProvider.of(context);
    return MaterialApp(
      // Remove Debug flag to allow app to be production ready.
      debugShowCheckedModeBanner: false,
      title: 'Utopian Rocks Mobile',
      // Setup theme data for Utopian Lato font and Color
      theme: ThemeData(
        fontFamily: 'Lato-Regular',
        primaryColor: Color(0xff24292e),
        accentColor: Color(0xff26A69A),
      ),
      // Setup the tab controller for the two different tabs.
      home: DefaultTabController(
        length: 2,
        child: StreamBuilder(
          stream: informationBloc.infoStream,
          builder: (context, snapshot) => Scaffold(
                appBar: AppBar(
                  // [Flex] allows the image and title to be on the same line in the [AppBar].
                  // Use [MainAxisAlignment.spaceEvenly] to add space between the two widgets.
                  title: Flex(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Image.asset(
                          'assets/images/utopy.png',
                        ),
                      ),
                      Text(
                        'Utopian Rocks Mobile',
                      ),
                    ],
                  ),

                  // Add [TabBar] to the [AppBar] to allow the user to navigate from one page to the next.
                  bottom: TabBar(
                    tabs: <Widget>[
                      Tab(
                          icon: Icon(Icons.rate_review),
                          text: 'Waiting for Review'),
                      Tab(
                          icon: Icon(Icons.hourglass_empty),
                          text: 'Waiting on Upvote'),
                    ],
                  ),
                ),
                // Body of the application which points towards the two pages.
                // Page one lists the unreviewed contributions and Page two lists the pending contributions.
                body: TabBarView(
                  children: <Widget>[
                    ListPage('unreviewed'),
                    ListPage('pending'),
                  ],
                ),
                bottomNavigationBar:
                    _buildBottonSheet(context, contributionBloc),
                endDrawer: InformationDrawer(snapshot),
              ),
        ),
      ),
    );
  }

  Widget _buildBottonSheet(
    BuildContext context,
    ContributionBloc contributionBloc,
  ) {
    return StreamBuilder(
        stream: contributionBloc.voteCount,
        builder: (context, votecountSnapshot) => BottomAppBar(
            color: Color(0xff26A69A),
            child: Row(
              children: [
                StreamBuilder(
                    stream: contributionBloc.timer,
                    builder: (context, timerSnapshot) {
                      return Text(
                        'Next Vote Cycle: ${DateFormat.Hms().format(DateTime(0, 0, 0, 0, 0, timerSnapshot.data ?? 0))} ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      );
                    }),
                Text(
                  'Vote Power: ${double.parse(votecountSnapshot.data ?? '0.0').toStringAsPrecision(4)}',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                _generateMenu(categories, contributionBloc),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
            )));
  }

  Widget _generateMenu(
    List<String> categories,
    ContributionBloc bloc,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'Filter Contribution Categories',
      onSelected: (category) => bloc.filter.add(category),
      itemBuilder: (context) => categories
          .map((cate) => PopupMenuItem(
                height: 40.0,
                value: cate,
                child: ListTile(
                  leading: Icon(
                    IconData(
                      icons[cate],
                      fontFamily: 'Utopicons',
                    ),
                    color: colors[cate],
                  ),
                  title: Text(cate),
                ),
              ))
          .toList(),
    );
  }
}
