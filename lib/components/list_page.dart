import 'package:flutter/material.dart';
import 'package:utopian_rocks/providers/contribution_provider.dart';
import 'package:utopian_rocks/utils/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import 'package:intl/intl.dart';

import 'package:utopian_rocks/model/htmlParser.dart';

class ListPage extends StatelessWidget {
  final String tabname;

  ListPage(this.tabname);

  @override
  Widget build(BuildContext context) {
    // get block from [ContributionProvider] to add to [StreamBuilder]
    final bloc = ContributionProvider.of(context);
    final parseWebsite = ParseWebsite();
    // Pass in the [tabname] or string which represents the page name.
    // Based on the string passed in, the stream will get different contributions.
    bloc.tabname.add(tabname);

    parseWebsite.getHtml();

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

        bloc.voteCount.listen((vc) => showBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                color: Color(0xff26A69A),
                child: Row(
                  children: [
                    StreamBuilder(
                        stream: bloc.timer,
                        builder: (context, timerSnapshot) {
                          return Text(
                            '~ Next Vote Cycle: ${DateFormat.Hms().format(DateTime(0, 0, 0, 0, 0, timerSnapshot.data ?? 0))} ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          );
                        }),
                    Text(
                      'Vote Power: ${double.parse(vc.replaceAll('\n', '')).toStringAsPrecision(4)}',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              );
            }));

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
                    String created = convertTimestamp(snapshot, index);
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
  // Timestamp displayed is based on the tabname.  If unreviewed, display created if reviewed display reviewDate.
  String convertTimestamp(AsyncSnapshot snapshot, int index) {
    if (tabname == 'unreviewed') {
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
