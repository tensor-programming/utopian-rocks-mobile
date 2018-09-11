import 'package:flutter/material.dart';
import 'package:utopian_rocks/provider.dart';
import 'package:utopian_rocks/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share/share.dart';

class ListPage extends StatelessWidget {
  final String tabname;

  ListPage(this.tabname);

  @override
  Widget build(BuildContext context) {
    // get block from [ContributionProvider] to add to [StreamBuilder]
    final bloc = ContributionProvider.of(context);
    // Pass in the [tabname] or string which represents the page name.
    // Based on the string passed in, the stream will get different contributions.
    bloc.tabname.add(tabname);

    // [StreamBuilder] auto-updates the data based on the incoming steam from the BLoC
    return StreamBuilder(
      stream: bloc.results,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // If stream hasn't presented data yet, show a [CircularProgressIndicator]
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Generate [ListView] using the [AsyncSnapshot] from the [StreamBuilder]
        // [ListView] provides lazy loading and programmatically generates the Page.
        return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              // Format the data using appropriate methods.
              String repo = checkRepo(snapshot, index);
              String created = convertTimestamp(snapshot, index);
              Color categoryColor = getCategoryColor(snapshot, index);
              int iconCode = getIcon(snapshot, index);

              // [ListTile] is the main body for each Contribution
              return ListTile(
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
                ),
                // A gesture detector to allow the user to open the article in a browser window or share it.
                title: GestureDetector(
                  // Contribution Title with formated text.
                  child: Text(
                    '${snapshot.data[index].title}',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  // Using the share library to deploy a share intent on both android and iOS with the contribution url.
                  onDoubleTap: () {
                    Share.share('${snapshot.data[index].url}');
                  },
                ),
                // Subtitle takes the repo name and formatted timestamp and displays them below Title
                subtitle: Text(
                  "$repo - $created",
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Get icon from utopicons font family and color it based on the category.
                trailing: Icon(
                  IconData(iconCode ?? 0x0000, fontFamily: 'Utopicons'),
                  color: categoryColor,
                ),
              );
            });
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
  // Timestamp displayed is based on the tabname.  If unreviewed, display created if reviewed display reviewDate.
  String convertTimestamp(AsyncSnapshot snapshot, int index) {
    if (tabname == 'unreviewed') {
      return "Created: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data[index].created))}";
    } else {
      return "Reviewed: ${timeago.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data[index].reviewDate))}";
    }
  }
}
