import 'package:flutter/material.dart';
import 'package:utopian_rocks/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:utopian_rocks/model/htmlParser.dart';
import 'package:utopian_rocks/blocs/contribution_bloc.dart';

class ListPage extends StatelessWidget {
  final ContributionBloc bloc;
  final String tabName;
  final Function(int, ContributionBloc) callback;

  ListPage(this.tabName, this.bloc, this.callback);
  // Pass in the [tabName] or string which represents the page name.
  // Based on the string passed in, the stream will get different contributions.

  @override
  Widget build(BuildContext context) {
    // get block from [ContributionProvider] to add to [StreamBuilder]
    final parseWebsite = ParseWebsite();
    final tab = DefaultTabController.of(context);
    callback(tab.index, bloc);

    parseWebsite.getHtml();

    // [StreamBuilder] auto-updates the data based on the incoming steam from the BLoC
    return StreamBuilder(
      stream: bloc.filteredResults,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // callback(bloc, context);
        // If stream hasn't presented data yet, show a [CircularProgressIndicator]
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Generate [ListView] using the [AsyncSnapshot] from the [StreamBuilder]
        // [ListView] provides lazy loading and programmatically generates the Page.
        return Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    // Format the data using appropriate methods.
                    String repo = checkRepo(snapshot, index);
                    String created = convertTimestamp(snapshot, index, tabName);
                    Color categoryColor = getCategoryColor(snapshot, index);
                    int iconCode = getIcon(snapshot, index);

                    // A [GestureDetector] to allow the user to open the article in a browser window or share it.
                    return GestureDetector(
                      // [ListTile] is the main body for each Contribution
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                // Get user name and then get the avatar from steemitimages.com
                                image: NetworkImage(
                                  'https://steemitimages.com/u/${snapshot.data[index].author}/avatar',
                                ),
                              ),
                            ),
                          ),
                          backgroundColor: Colors.white,
                        ),

                        // Contribution Title with formated text.
                        title: Text(
                          '${snapshot.data[index].title}',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        // Subtitle takes the repo name and formatted timestamp and displays them below Title
                        subtitle: Text(
                          "$repo - $created",
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Get icon from utopicons font family and color it based on the category.
                        trailing: Icon(
                          IconData(iconCode ?? 0x0000, fontFamily: 'Utopicons'),
                          color: categoryColor,
                        ),
                      ),
                      // Using the share library to deploy a share intent on both android and iOS with the contribution url.
                      onDoubleTap: () async {
                        await _launchUrl(snapshot.data[index].url);
                      },
                    );
                  }),
            ),
          ],
        );
      },
    );
  }

  // Check that repository exists, if it doesn't exist add default message.
  String checkRepo(AsyncSnapshot snapshot, int index) {
    if (snapshot.data[index].repository != "") {
      return snapshot.data[index].repository;
    } else {
      return 'No Repository';
    }
  }

  // Using the timeago dart librarty to format the timestamps to create "fuzzy timestamps" for the contributions
  // Timestamp displayed is based on the tabName.  If unreviewed, display created if reviewed display reviewDate.
  String convertTimestamp(AsyncSnapshot snapshot, int index, String tabName) {
    if (tabName == 'unreviewed') {
      return "Created: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data[index].created))}";
    } else {
      return "Reviewed: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data[index].reviewDate))}";
    }
  }

  // Laucn the steemit/utopian url using the url_launcher package.
  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      print('Launching: $url');
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
